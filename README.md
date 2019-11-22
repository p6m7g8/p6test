### _bootstrap.sh:
- p6_p6test_bootstrap([dir=$P6_DFZ_SRC_P6M7G8_DIR/p6test])

### _colors.sh:
- p6_test_colorize_bail(line)
- p6_test_colorize_block(line)
- p6_test_colorize_diagnostic(line)
- p6_test_colorize_not_ok(line)
- p6_test_colorize_ok(line)
- p6_test_colorize_plan(line)
- p6_test_colorize_skip(line)
- p6_test_colorize_todo(line)

### _util.sh:
- p6_test_dir(test_path)

### api.sh:
- p6_test_bail(reason)
- p6_test_diagnostic(msg)
- p6_test_finish()
- p6_test_not_ok(description)
- p6_test_ok(description)
- p6_test_setup(n)
- p6_test_skip(description, reason)
- p6_test_start(block)
- p6_test_teardown()
- p6_test_todo(val, const, description, reason)

### aserts.sh:
- p6_test_assert_blank(val, description, reason)
- p6_test_assert_contains(val, const, description, reason)
- p6_test_assert_dir_exists(val, description, reason)
- p6_test_assert_dir_not_exists(val, description, reason)
- p6_test_assert_eq(val, const, description, reason)
- p6_test_assert_file_exists(val, description, reason)
- p6_test_assert_file_matches(file1, file2, description, reason)
- p6_test_assert_file_not_exists(val, description, reason)
- p6_test_assert_len(val, const, description, reason)
- p6_test_assert_not_blank(val, description, reason)
- p6_test_assert_not_contains(val, const, description, reason)
- p6_test_assert_not_eq(val, const, description, reason)
- p6_test_assert_run_no_output(description, reason)
- p6_test_assert_run_no_stderr(description, reason)
- p6_test_assert_run_no_stdout(description, reason)
- p6_test_assert_run_not_ok(description, reason)
- p6_test_assert_run_ok(description, [rv=0], [stdout=], [stderr=])
- p6_test_assert_run_rc(description, rv)
- p6_test_run()
- p6_test_run_rc()
- p6_test_run_stderr()
- p6_test_run_stdout()

### tap.sh:
- p6_test_tap_bail_out(reason)
- p6_test_tap_block(block)
- p6_test_tap_diagnostic(msg)
- p6_test_tap_not_ok(description, reason)
- p6_test_tap_ok(description, reason)
- p6_test_tap_plan(n)
- p6_test_tap_shell()
- p6_test_tap_skip(description, reason)
- p6_test_tap_todo_bonus(description, reason)
- p6_test_tap_todo_planned(description, reason)

### bench.sh:
- p6_test_bench(times, thing)

### harness.sh:
- p6_test_harness_test_run()
- p6_test_harness_tests_run(dir)

