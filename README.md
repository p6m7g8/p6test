p6test/
  Tester (api.sh)
    Backends
      Tap (tap.sh)
  Harness 
  Asserts (asserts.sh)
  Colorizer (colors.sh)

# Assertions
- p6_test_assert_blank()
- p6_test_assert_contains()
- p6_test_assert_eq()
- p6_test_assert_not_blank()
- p6_test_assert_not_contains()
- p6_test_assert_not_eq()
- p6_test_assert_run_not_ok()
- p6_test_assert_run_ok()

# Run function or cmd
- p6_test_run()
- p6_test_run_stderr()
- p6_test_run_stdout()

# Test API
- p6_test_bail()
- p6_test_diagnostic()
- p6_test_dir()
- p6_test_finish()
- p6_test_setup()
- p6_test_skip()
- p6_test_start()
- p6_test_teardown()
- p6_test_todo()

# Tap backend
- p6_test_tap_bail_out()
- p6_test_tap_block()
- p6_test_tap_diagnostic()
- p6_test_tap_not_ok()
- p6_test_tap_ok()
- p6_test_tap_plan()
- p6_test_tap_shell()
- p6_test_tap_skip()
- p6_test_tap_todo()

# Colorizers
- p6_test_colorize_bail()
- p6_test_colorize_block()
- p6_test_colorize_diagnostic()
- p6_test_colorize_not_ok()
- p6_test_colorize_ok()
- p6_test_colorize_plan()
- p6_test_colorize_skip()
- p6_test_colorize_todo()
