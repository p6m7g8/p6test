##############################################################################
#
# Runing something
#
# /tmp/p6test
# /tmp/p6test/i
# /tmp/p6test/n
# /tmp/p6test/t/
# /tmp/p6test/t/<rand>/
# /tmp/p6test/t/<rand>/stdin
# /tmp/p6test/t/<rand>/stdout
# /tmp/p6test/t/<rand>/stderr
# /tmp/p6test/t/<rand>/rv
#
# XXX: fixtures and stdin
###############################################################################
p6_test_run() {
    local func="$1"
    local args="$@"

    local dir=$(p6_test_dir)

    local stdin=$dir/in
    local stdout=$dir/stdout
    local stderr=$dir/stderr
    local rv=$dir/rv

    eval "$func" >$stdout 2>$stderr
    local rc=$?
    echo $rc > $rv
}

p6_test_run_stdout() {

    local dir=$(p6_test_dir)
    cat $dir/stdout
}

p6_test_run_stderr() {

    local dir=$(p6_test_dir)
    cat $dir/stderr
}

##############################################################################
#
# Assertions.
#
#
#
###############################################################################
p6_test_assert_run_ok() {
    local description="$1"
    local reason="$2"

    local dir=$(p6_test_dir)
    local rc=$(cat $dir/rv)

    p6_test_assert_eq "$rc" "0" "$description" "$reason"

    echo $rc
}

p6_test_assert_run_not_ok() {
    local description="$1"
    local reason="$2"

    local dir=$(p6_test_dir)
    local rc=$(cat $dir/rv)

    p6_test_assert_ne "$rc" "0" "$description" "$reason"

    echo $rc
}

p6_test_assert_eq() {
    local val="$1"
    local const="$2"
    local description="$3"
    local reason="$4"

    local rv=-1
    case $val in
	$const)
	    rv=1
	    p6_test_tap_ok "$description" "$reason"
	    ;;
	*)
	    rv=0
	    p6_test_tap_not_ok "$description" "$reason"
	    ;;
    esac

    return $rv
}

p6_test_assert_not_eq() {
    local val="$1"
    local const="$2"
    local description="$3"
    local reason="$4"

    local rv=-1
    case $val in
	$const)
	    rv=0
	    p6_test_tap_not_ok "$description" "$reason"
	    ;;
	*)
	    rv=1
	    p6_test_tap_ok "$description" "$reason"
	    ;;
    esac

    return $rv
}

p6_test_assert_contains() {
    local val="$1"
    local const="$2"
    local description="$3"
    local reason="$4"

    local rv=-1
    case $const in
	$val)
	    rv=1
	    p6_test_tap_ok "$description" "$reason"
	    ;;
	*)
	    rv=0
	    p6_test_tap_not_ok "$description" "$reason"
	    ;;
    esac

    return $rv

}

p6_test_assert_not_contains() {
    local val="$1"
    local const="$2"
    local description="$3"
    local reason="$4"

    local rv=-1
    case $const in
	$val)
	    rv=0
	    p6_test_tap_not_ok "$description" "$reason"
	    ;;
	*)
	    rv=1
	    p6_test_tap_ok "$description" "$reason"
	    ;;
    esac

    return $rv

}

p6_test_assert_blank() {
    local val="$1"
    local description="$2"
    local reason="$3"

    local rv=-1
    if [ -z "$val" ]; then
	rv=1
	p6_test_tap_ok "$description" "$reason"
    else
	rv=0
	p6_test_tap_not_ok "$description" "$reason"
    fi

    return $rv
}

p6_test_assert_not_blank() {
    local val="$1"
    local description="$2"
    local reason="$3"

    local rv=-1
    if [ -n "$val" ]; then
	rv=1
	p6_test_tap_ok "$description" "$reason"
    else
	rv=0
	p6_test_tap_not_ok "$description" "$reason"
    fi

    return $rv

}
