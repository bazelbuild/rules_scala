#!/usr/bin/env bash

set -eou pipefail

dir="${BASH_SOURCE[0]%/*}"
dir="$( cd "${dir:-.}" && pwd )"

bazel run //tools:lint_check

RULES_SCALA_TEST_ONLY="${RULES_SCALA_TEST_ONLY:-}"
RULES_SCALA_TEST_VERBOSE="${RULES_SCALA_TEST_VERBOSE:-}"
. "${dir}/test/shell/test_bzlmod_tidy.sh"
