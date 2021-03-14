# p6test

## Table of Contents


### p6test
- [p6test](#p6test)
  - [Badges](#badges)
  - [Distributions](#distributions)
  - [Summary](#summary)
  - [Contributing](#contributing)
  - [Code of Conduct](#code-of-conduct)
  - [Changes](#changes)
    - [Usage](#usage)
  - [Author](#author)

### Badges

[![License](https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg)](https://opensource.org/licenses/Apache-2.0)
[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/p6m7g8/p6test)
[![Mergify](https://img.shields.io/endpoint.svg?url=https://gh.mergify.io/badges/p6m7g8/p6test/&style=flat)](https://mergify.io)
[![codecov](https://codecov.io/gh/p6m7g8/p6test/branch/master/graph/badge.svg?token=14Yj1fZbew)](https://codecov.io/gh/p6m7g8/p6test)
[![Known Vulnerabilities](https://snyk.io/test/github/p6m7g8/p6test/badge.svg?targetFile=package.json)](https://snyk.io/test/github/p6m7g8/p6test?targetFile=package.json)
[![Gihub repo dependents](https://badgen.net/github/dependents-repo/p6m7g8/p6test)](https://github.com/p6m7g8/p6test/network/dependents?dependent_type=REPOSITORY)
[![Gihub package dependents](https://badgen.net/github/dependents-pkg/p6m7g8/p6test)](https://github.com/p6m7g8/p6test/network/dependents?dependent_type=PACKAGE)

## Summary

## Contributing

- [How to Contribute](CONTRIBUTING.md)

## Code of Conduct

- [Code of Conduct](https://github.com/p6m7g8/.github/blob/master/CODE_OF_CONDUCT.md)

## Changes

- [Change Log](CHANGELOG.md)

## Usage

### p6test:

#### p6test/init.zsh:

- p6df::modules::p6test::init()

### ../p6test/lib:

#### ../p6test/lib/_bootstrap.sh:

- p6_p6test_bootstrap([dir=$P6_DFZ_SRC_P6M7G8_DIR/p6test])
#### ../p6test/lib/_colors.sh:

- p6_test_colorize_bail(line)
- p6_test_colorize_block(line)
- p6_test_colorize_diagnostic(line)
- p6_test_colorize_not_ok(line)
- p6_test_colorize_ok(line)
- p6_test_colorize_plan(line)
- p6_test_colorize_skip(line)
- p6_test_colorize_todo(line)
#### ../p6test/lib/_util.sh:

- p6_test_dir(test_path)
#### ../p6test/lib/api.sh:

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
#### ../p6test/lib/bench.sh:

- p6_test_bench(times, thing)
#### ../p6test/lib/harness.sh:

- p6_test_harness_test_run()
- p6_test_harness_tests_run(dir)

### asserts:

#### asserts/aserts.sh:

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

### backends:

#### backends/tap.sh:

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


## Author

Philip M . Gollucci <pgollucci@p6m7g8.com>
