##############################################################################
#
# #!/bin/sh -e
#
# p6_test_setup "n"
#
# p6_test_start "block"
# (
#    p6_test_run "func" "args..."
#    p6_test_assert_run_ok     "description"
#    p6_test_assert_run_not_ok "description"
#
#    p6_test_assert_eq         "$val" "const" "description"
#    p6_test_assert_contains   "$val" "const" "description"
#    p6_test_assert_true       "$val" "description"
#    p6_test_assert_false      "$val" "description"
#    p6_test_assert_blank      "$val" "description"
#    p6_test_assert_not_blank  "$val" "description"
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
