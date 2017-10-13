p6_test_harness_test_run() {
    local file="$1"

    local t=0
    local i=0
    local s=0
    local S=0
    local T=0
    local F=0

    local test_env=$(env | egrep "^(EDITOR|DISPLAY|HOME|PWD|SHELL|SHLVL|TMPDIR|USER|TERM)=")
    test_env="$test_env P6_TEST_COLOR_OFF=1"

    local d0=$(date "+%s")
    if [ -n "$P6_TEST_VERBOSE" ]; then
	env -i $test_env /bin/sh $file | tee /tmp/p6-foo.log
    else
	env -i $test_env /bin/sh $file > /tmp/p6-foo.log
    fi
    local dn=$(date "+%s")
    local d=$(($dn-$d0))

    local line
    local IFS='
'
    for line in $(cat /tmp/p6-foo.log); do
	case $line in
	    1..*)
		t=$(echo $line | sed -e 's,^1..,,')
		;;
	    ok\ *SKIP*\ *)
		S=$(($s+1))
		;;
	    not\ *TODO\ *)
		T=$(($c+1))
		;;
	    not\ ok*)
		F=$(($f+1))
		;;
	    ok\ *)
		s=$(($i+1))
		;;
	esac
    done

    local r=$(($S+$T+$F+$s))
    local P=$(($S+$s))
    local p=$(echo "scale=2; ($P/$t)*100" | bc -lq)

    echo "$t $i $s $S $T $F $r $p $P $d"
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
	local ti=$(echo $vals | awk '{ print $1 }')
	local Pi=$(echo $vals | awk '{ print $9 }')
	local di=$(echo $vals | awk '{ print $10 }')

	d=$(($d+$di))
	P=$(($P+$Pi))
	t=$(($t+$ti))
	f=$(($f+1))
    done

    local result
    if [ $P -ne $t ]; then
	result=FAIL
    else
	result=PASS
    fi

    echo "msg"
    echo "Files=$f, Tests=$t, $d wallclock secs"
    echo "Result: $result"
}
