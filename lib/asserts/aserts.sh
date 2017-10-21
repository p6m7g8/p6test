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

    local dir=$(p6_test_dir)

    local cli=$dir/cli
    local stdin=$dir/in
    local stdout=$dir/stdout
    local stderr=$dir/stderr
    local rv=$dir/rv

    echo "$@" > $dir/cli
    eval "$@" >$stdout 2>$stderr
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

p6_test_run_rc() {

    local dir=$(p6_test_dir)
    cat $dir/rv
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
    local rv="${2:-0}"

    p6_test_assert_run_rc "$description" "$rv"
    p6_test_assert_run_no_output "$description"
}

p6_test_assert_run_rc() {
    local description="$1"
    local rv="$2"

    local rc=$(p6_test_run_rc)

    if p6_test_assert_eq "$rc" "$rv" "$description" "$reason"; then
	p6_test_tap_diagnostic "stdout: $(p6_test_run_stdout)"
	p6_test_tap_diagnostic "stderr: $(p6_test_run_stderr)"
    fi
}

p6_test_assert_run_no_output() {
    local description="$1"
    local reason="$2"

    p6_test_assert_run_no_stdout "$description" "$reason"
    p6_test_assert_run_no_stderr "$description" "$reason"
}

p6_test_assert_run_no_stdout() {
    local description="$1"
    local reason="$2"

    p6_test_assert_blank "$(p6_test_run_stdout)" "$description: no stdout"
}

p6_test_assert_run_no_stderr() {
    local description="$1"
    local reason="$2"

    p6_test_assert_blank "$(p6_test_run_stderr)" "$description: no stderr"
}

p6_test_assert_run_not_ok() {
    local description="$1"
    local reason="$2"

    local dir=$(p6_test_dir)
    local rc=$(cat $dir/rv)

    p6_test_assert_not_eq "$rc" "0" "$description" "$reason"
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
	    p6_test_tap_diagnostic "expected [$const], got [$val]"
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
	    p6_test_tap_diagnostic "expected [$const], got [$val]"
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
    case $val in
	$const)
	    rv=1
	    p6_test_tap_ok "$description" "$reason"
	    ;;
	*)
	    rv=0
	    p6_test_tap_not_ok "$description" "$reason"
	    p6_test_tap_diagnostic "expected [$const], got [$val]"
	    ;;
    esac

    return $rv
}

p6_test_assert_len() {
    local val="$1"
    local const="$2"
    local description="$3"
    local reason="$4"

    local len=$(echo $val | wc -m | awk '{print $1}')
    len=$(($len-1))

    p6_test_assert_eq "$len" "$const" "$description" "$reason"
}

p6_test_assert_not_contains() {
    local val="$1"
    local const="$2"
    local description="$3"
    local reason="$4"

    local rv=-1
    case $val in
	$const)
	    rv=0
	    p6_test_tap_not_ok "$description" "$reason"
	    p6_test_tap_diagnostic "expected [$const], got [$val]"
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
	p6_test_tap_diagnostic "[$val] is not blank"
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
	p6_test_tap_diagnostic "[$val] is not blank"
    fi

    return $rv
}