# t - total number of planed tests. From the TAP plan.
# s - number of tests ok (includes TODO tests not accidentally passing)
# S - number of tests SKIPPED
# T - number of tests TODO (currently correctly failing as its TODO)
# B - GOOD NEWS, number of tests accidentally passing, REMOVE TODO.
# F - BAD NEWS, you have bugs, number of tests not ok
# r - number of tests run (S+T+F+s)
# P - number of tests ok (S+s+T)
# p - percentage of tests passing (P/t)*100
# d - time delta

p6_test_harness_test_run() {
    local file="$1"

    local t=0
    local S=0
    local T=0
    local B=0
    local F=0
    local s=0

    ## Setup env
    local test_env=$(env | egrep "^(EDITOR|DISPLAY|HOME|PWD|SHELL|SHLVL|TMPDIR|USER|TERM|PATH|P6_TEST_)=")

    # Log file
    local log_file=/tmp/p6/test/tests/$(basename $file).txt
    local log_file_times=$log_file-time
    mkdir -p $(dirname $log_file)

    # Dupe and redirect
    exec 3>&1 4>&2 >$log_file 2>$log_file_times

    ## Time and run
    chmod 755 $file
    time env -i P6_TEST_COLOR_OFF=1 $test_env ./$file

    # Restore
    exec 1>&3 2>&4

    local IFS='
'

    local line
    for line in $(cat $log_file); do
	case $line in
	    1..*)
		t=$(echo $line | sed -e 's,^1..,,' -e 's, *,,')
		;;
	    ok\ *SKIP*\ *)
		S=$(($S+1))
		;;
	    not\ *TODO\ *)
		T=$(($T+1))
		;;
	    ok\ *TODO\ *)
		B=$(($B+1))
		s=$(($s+1))
		;;
	    not\ ok*)
		F=$(($F+1))
		;;
	    ok\ *)
		s=$(($s+1))
		;;
	esac
    done

#    if [ $F -eq 0 ]; then
#	rm -f $log_file
#    fi

    local r=$(($S+$T+$F+$s))
    local P=$(($S+$s+$T))

    local p
    case $t in
	0) p=0.00 ;;
	*) p=$(echo "scale=3; ($P/$t)*100" | bc -lq) ;;
    esac

    # 0m0.330s
    local d=$(awk '/real/ { print $2 }' $log_file_times | sed -e 's,^0m,,' -e 's/s//')
    if [ -z "$d" ]; then
      d=0
    fi

    echo "t=$t, s=$s, S=$S, T=$T, B=$B, F=$F, r=$r, p=$p, P=$P, d=$d"
    echo "t=$t, s=$s, S=$S, T=$T, B=$B, F=$F, r=$r, p=$p, P=$P, d=$d" >&2
}

p6_test_harness_tests_run() {
    local dir="$1"

    local f=0
    local t=0
    local i=0
    local s=0
    local S=0
    local T=0
    local B=0
    local F=0
    local r=
    local p=0
    local P=
    local d=0

    local file
    for file in $(cd $dir ; ls -1); do
	local vals=$(p6_test_harness_test_run "$dir/$file")
	local ti=$(echo $vals | grep -o 't=[0-9]*'       | sed -e 's,t=,,')
	local pi=$(echo $vals | grep -o 'p=[0-9\.]*'     | sed -e 's,p=,,')
	local Pi=$(echo $vals | grep -o 'P=[0-9]*'       | sed -e 's,P=,,')
	local Si=$(echo $vals | grep -o 'S=[0-9]*'       | sed -e 's,S=,,')
	local Ti=$(echo $vals | grep -o 'T=[0-9]*'       | sed -e 's,T=,,')
	local Bi=$(echo $vals | grep -o 'B=[0-9]*'       | sed -e 's,B=,,')
	local di=$(echo $vals | grep -o 'd=[0-9.\-]*'    | sed -e 's,d=,,')

        echo "t=[$t], ti=[$ti]"
        echo "P=[$P], Pi=[$Pi]"
        echo "B=[$B], Bi=[$Bi]"
        echo "S=[$S], Si=[$Si]"
        echo "T=[$T], Ti=[$Ti]"
        echo "p=[$p], pi=[$pi]"
        echo "d=[$d], di=[$di]"
	t=$(($t+$ti))
	P=$(($P+$Pi))
	B=$(($B+$Bi))
	S=$(($S+$Si))
	T=$(($T+$Ti))
	p=$(echo "$p+$pi" | bc -q)
	d=$(echo "$d+$di" | bc -q)

	p6_test_harness___results "$dir/$file" "$di" "$pi" "$Pi" "$ti" "$Bi" "$Ti" "$Si" >&2
	f=$(($f+1))
    done

    local result
    local msg
    if [ x"$P" != x"$t" ]; then
	msg=$(egrep '^not ok|^#' /tmp/p6/test/tests/*.txt)
	result=FAIL
    else
	msg=ok
	if [ $B -gt 0 ]; then
	    result=PROVISIONAL
	else
	    result=PASS
	fi
    fi

    echo "$msg"
    echo "Files=$f, Tests=$P/$t, Todo=$T, Fixed=$B, Skipped=$S, $d wallclock secs"
    echo "Result: $result"
    rm -rf /tmp/p6/test
}

p6_test_harness___results() {
    local name="$1"
    local duration="$2"
    local prcnt_passed="$3"
    local passed="$4"
    local total="$5"
    local bonus="$6"
    local todo="$7"
    local skipped="$8"

    local len=${#name}

    local line=$name
    local i=$len
    while [ $i -lt 48 ]; do
	line="$line."
	i=$(($i+1))
    done

    passed=$(p6_test_harness__zero_lpad "3" "$passed")
    total=$(p6_test_harness__zero_lpad "3" "$total")

    line="$line ${duration}s $passed/$total $prcnt_passed%"
    if [ $bonus -gt 0 ]; then
	line="$line [$bonus now pass]"
    else
	if [ $todo -gt 0 ]; then
	    line="$line, todo=$todo"
	fi
    fi
    if [ $skipped -gt 0 ]; then
	line="$line, skipped=$skipped"
    fi

    local color
    if [ $passed -eq $total ]; then
	if [ $bonus -gt 0 ]; then
	    color=yellow
	else
	    color=green
	fi
    else
	color=red
    fi
    p6_test_colorize__say "$color" "black" "$line"
}

p6_test_harness__zero_lpad() {
    local len="$1"
    local str="$2"

    local str_len=${#str}

    local i=$str_len
    while [ $i -lt $len ]; do
	str="0$str"
	i=$(($i+1))
    done

    echo "$str"
}
