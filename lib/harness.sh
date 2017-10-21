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
# lf- log_file, will be -e if F > 0
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
    local log_file=/tmp/p6-test-$(echo $file | md5).txt
    local log_file_times=$log_file-time

    # Dupe and redirect
    exec 3>&1 4>&2 >$log_file 2>$log_file_times

    ## Time and run
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
    rm -f $log_file

    local r=$(($S+$T+$F+$s))
    local P=$(($S+$s+$T))

    local p
    case $t in
	0) p=0.00 ;;
	*) p=$(echo "scale=2; ($P+$T/$t)*100" | bc -lq) ;;
    esac

    echo "t=$t, s=$s, S=$S, T=$T, B=$B, F=$F, r=$r, p=$p, P=$P, dp=$dp"
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
    local p=
    local P=
    local d=0

    local file
    for file in $(cd $dir ; ls -1); do
	local vals=$(p6_test_harness_test_run "$dir/$file")
	local ti=$(echo $vals | grep -o 't=[0-9]*'   | sed -e 's,t=,,')
	local Pi=$(echo $vals | grep -o 'P=[0-9]*'   | sed -e 's,P=,,')
	local Si=$(echo $vals | grep -o 'S=[0-9]*'   | sed -e 's,S=,,')
	local Ti=$(echo $vals | grep -o 'T=[0-9]*'   | sed -e 's,T=,,')
	local Bi=$(echo $vals | grep -o 'B=[0-9]*'   | sed -e 's,B=,,')
	local di=$(echo $vals | grep -o 'dp=[0-9.\-]*' | sed -e 's,dp=,,')

	t=$(($t+$ti))
	P=$(($P+$Pi))
	B=$(($B+$Bi))
	S=$(($S+$Si))
	T=$(($T+$Ti))
	d=$(echo "$d+$di" | bc -lq)

	p6_test_harness___results "$dir/$file" "${di}" "$Pi" "$ti" "$Bi" "$Ti" "$Si"
	f=$(($f+1))
    done

    local result
    local msg
    if [ x"$P" != x"$t" ]; then
	msg=results
	result=FAIL
    else
	msg=ok
	if [ $B -gt 0 ]; then
	    result=PROVISIONAL
	else
	    result=PASS
	fi
    fi

    case $d in
	.[0-9]*) d="0$d" ;;
    esac

    echo "$msg"
    echo "Files=$f, Tests=$P/$t, Todo=$T, Fixed=$B, Skipped=$S, $d wallclock secs"
    echo "Result: $result"
}

p6_test_harness___results() {
    local name="$1"
    local duration="$2"
    local passed="$3"
    local total="$4"
    local bonus="$5"
    local todo="$6"

    case $duration in
	.[0-9]*) duration="0$duration" ;;
    esac

    local len=$(echo $name | wc -m | awk '{print $1}')
    len=$(($len-1))

    local line=$name
    local i=$len
    while [ $i -lt 48 ]; do
	line="$line."
	i=$(($i+1))
    done

    if [ $bonus -gt 0 ]; then
	line="$line ${duration}s $passed/$total [$bonus now pass]"
    else
	if [ $todo -gt 0 ]; then
	    line="$line ${duration}s $passed/$total, todo=$todo"
	else
	    line="$line ${duration}s $passed/$total"
	fi
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
