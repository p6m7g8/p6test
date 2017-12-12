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

    local Tt=0
    local Ts=0
    local TS=0
    local TT=0
    local TB=0
    local TF=0

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
		Tt=$(echo $line | sed -e 's,^1..,,' -e 's, *,,')
		;;
	    ok\ *SKIP*\ *)
		TS=$(($TS+1))
		;;
	    not\ *TODO\ *)
		TT=$(($TT+1))
		;;
	    ok\ *TODO\ *)
		TB=$(($TB+1))
		Ts=$(($Ts+1))
		;;
	    not\ ok*)
		TF=$(($TF+1))
		;;
	    ok\ *)
		Ts=$(($Ts+1))
		;;
	esac
    done

#    if [ $TF -eq 0 ]; then
#	rm -f $log_file
#    fi

    local Tr=$(($TS+$TT+$TF+$Ts))
    local TP=$(($TS+$Ts+$TT))

    local Tp
    case $Tt in
	0) Tp=0.00 ;;
	*) Tp=$(echo "scale=3; ($TP/$Tt)*100" | bc -lq) ;;
    esac

    # 0m0.330s
    local Td=$(awk '/real/ { print $2 }' $log_file_times | sed -e 's,^0m,,' -e 's/s//')
    if [ -z "$Td" ]; then
      Td=0
    fi

    Tt=1
    Ts=2
    TS=3
    TT=4
    TB=5
    TF=6
    Tr=7
    Tp=8
    TP=10
    Td=11

    echo "t=$Tt s=$Ts S=$TS T=$TT B=$TB F=$TF r=$Tr p=$Tp P=$TP d=T$d"
    echo "t=$Tt s=$Ts S=$TS T=$TT B=$TB F=$TF r=$Tr p=$Tp P=$TP d=T$d" >&2
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
    local P=0
    local d=0

    local file
    for file in $(cd $dir ; ls -1); do
	local vals=$(p6_test_harness_test_run "$dir/$file")

        echo "==============> BEFORE:"
#        echo "t=[$t], ti=[$ti]"
        echo "P=[$P], Pi=[$Pi]"
#        echo "B=[$B], Bi=[$Bi]"
#        echo "S=[$S], Si=[$Si]"
#        echo "T=[$T], Ti=[$Ti]"
#        echo "p=[$p], pi=[$pi]"
#        echo "d=[$d], di=[$di]"

#	local ti=$(echo $vals | grep -o 't=[0-9]*'       | sed -e 's,[^0-9],,g')
#	local pi=$(echo $vals | grep -o 'p=[0-9\.]*'     | sed -e 's,[^0-9],,g')
	local Pi=$(echo $vals | grep -o 'P=[0-9]*'       | sed -e 's,[^0-9],,g')
#	local Si=$(echo $vals | grep -o 'S=[0-9]*'       | sed -e 's,[^0-9],,g')
#	local Ti=$(echo $vals | grep -o 'T=[0-9]*'       | sed -e 's,[^0-9],,g')
#	local Bi=$(echo $vals | grep -o 'B=[0-9]*'       | sed -e 's,[^0-9],,g')
#	local di=$(echo $vals | grep -o 'd=[0-9.\-]*'    | sed -e 's,[^0-9],,g')

        echo "==============> AFTER:"
#        echo "t=[$t], ti=[$ti]"
        echo "P=[$P], Pi=[$Pi]"
#        echo "B=[$B], Bi=[$Bi]"
#        echo "S=[$S], Si=[$Si]"
#        echo "T=[$T], Ti=[$Ti]"
#        echo "p=[$p], pi=[$pi]"
#        echo "d=[$d], di=[$di]"

#	t=$(($t+$ti))
	P=$(($P+$Pi))
#	B=$(($B+$Bi))
#	S=$(($S+$Si))
#	T=$(($T+$Ti))
#	p=$(echo "$p+$pi" | bc -q)
#	d=$(echo "$d+$di" | bc -q)

        echo "==============> ITERATED:"
#        echo "t=[$t], ti=[$ti]"
        echo "P=[$P], Pi=[$Pi]"
#        echo "B=[$B], Bi=[$Bi]"
#        echo "S=[$S], Si=[$Si]"
#        echo "T=[$T], Ti=[$Ti]"
#        echo "p=[$p], pi=[$pi]"
#        echo "d=[$d], di=[$di]"

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
