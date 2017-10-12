##############################################################################
#
# #!/bin/sh
#
# p6_test_setup "5"
#
# p6_test_start "running things"
# (
#	p6_test_run "date" "args..."
#	p6_test_assert_run_ok "d1" "r1"
#	p6_test_assert_run_not_ok "d2" "r2"
# )
# p6_test_finish
#
# p6_test_start "directives 1"
# (
#	p6_test_skip "$code" "description" "bar"
#	echo "should not got here"
# )
# p6_test_finish
#
# p6_test_start "directives 2"
# (
#	p6_test_todo "$code" "description" "bar"
# )
#
# p6_test_finish
#
# p6_test_start "asserts"
# (
#     local val=1
#     p6_test_assert_eq        "$val" "1" "description" "reason"
#     p6_test_assert_eq        "$val" "0" "description"
#     p6_test_diagnostic       "expected [$val], got [0]"
#     p6_test_bail "gtfo"
#
#     p6_test_assert_contains   "$val" "const" "description" "reason"
#     p6_test_assert_blank      "$val" "description" "reason"
#     p6_test_assert_not_blank  "$val" "description" "reason"
# )
# p6_test_finish
#
# p6_test_start "should not run"
# (
#	local val=1
#	p6_test_assert_eq        "$val" "1" "description" "reason"
# )
# p6_test_finish
#
# p6_test_teardown
#
##############################################################################
p6_test_setup() {
    local n="$1"

    p6_test__initialize "$n"
    p6_test_tap_plan "$n"
}

p6_test_start() {
    local block="$1"

    p6_test__prep
    p6_test_tap_block "$block"
}

p6_test_skip() {
    local description="$1"
    local reason="$2"

    p6_test_tap_skip "$description" "$reason"
    exit 0
}

p6_test_todo() {
    local description="$1"
    local reason="$2"

    p6_test_tap_todo "$description" "$reason"
}

p6_test_diagnostic() {
    local msg="$1"

    p6_test_tap_diagnostic "$msg"
}

p6_test_bail() {
    local reason="$1"

    p6_test__bailout
    p6_test_tap_bail_out "$reason"
}

p6_test_finish() {

    local bail=$(p6_test__cleanup)
    if [ $bail -eq 1 ]; then
	exit 1
    fi
}

p6_test_teardown() {

    true
#    rm -rf $P6_TEST_DIR_BASE
}
