#!/usr/bin/env bash

set -eou pipefail

dir="${BASH_SOURCE[0]%/*}"
dir="$( cd "${dir:-.}" && pwd )"

bazel run //tools:lint_check
"${dir}/test/shell/test_bzlmod_tidy.sh"
