p6_test_harness_test_run() {
    local file="$1"

    local t=0
    local i=0
    local s=0
    local S=0
    local T=0
    local F=0

    ## Setup env
    local test_env=$(env | egrep "^(EDITOR|DISPLAY|HOME|PWD|SHELL|SHLVL|TMPDIR|USER|TERM)=")
    test_env="$test_env P6_TEST_COLOR_OFF=1"

    ## Time and run
    local dp0=$(perl -MTime::HiRes -e '($seconds, $microseconds) = Time::HiRes::gettimeofday(); print "$seconds.$microseconds"')

    P6_TEST_LOG_FILE=/tmp/p6-test.$$.tmp
    env -i $test_env /bin/sh $file > /tmp/p6-test.$$.tmp
    local dpn=$(perl -MTime::HiRes -e '($seconds, $microseconds) = Time::HiRes::gettimeofday(); print "$seconds.$microseconds"')

    ## Cal time
    local dp=$(echo "$dpn-$dp0" | bc -lq)

    local IFS='
'
    local line
    for line in $(cat $P6_TEST_LOG_FILE); do
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
	    not\ ok*)
		F=$(($F+1))
		;;
	    ok\ *)
		s=$(($s+1))
		;;
	esac
    done

    rm -f $P6_TEST_LOG_FILE

    local r=$(($S+$T+$F+$s))
    local P=$(($S+$s))
    local p=$(echo "scale=2; ($P/$t)*100" | bc -lq)

    echo "t=$t, i=$i, s=$s, S=$S, T=$T, F=$F, r=$r, p=$p, P=$P, dp=$dp"
}

p6_test_harness_tests_run() {
    local dir="$1"

    local f=0
    local t=0
    local i=0
    local s=0
    local S=0
    local T=0
    local F=0
    local r=
    local p=
    local P=
    local d=0

    local file
    for file in $(cd $dir ; ls -1); do
	local vals=$(p6_test_harness_test_run "$dir/$file")
	local ti=$(echo $vals | grep -o 't=[0-9]*'  | sed -e 's,t=,,')
	local Pi=$(echo $vals | grep -o 'P=[0-9]*'  | sed -e 's,P=,,')
	local di=$(echo $vals | grep -o 'dp=[.0-9]*' | sed -e 's,dp=,,')

	t=$(($t+$ti))
	P=$(($P+$Pi))
	d=$(echo "$d+$di" | bc -lq)

	f=$(($f+1))
    done

    local result
    local msg
    if [ $P -ne $t ]; then
	msg=results
	result=FAIL
    else
	msg=ok
	result=PASS
    fi

    case $d in
	.[0-9]*) d="0$d" ;;
    esac

    echo "$msg"
    echo "Files=$f, Tests=$t, $d wallclock secs"
    echo "Result: $result"
}
