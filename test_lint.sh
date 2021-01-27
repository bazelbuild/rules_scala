#!/usr/bin/env bash

set -eou pipefail
lint_command="${1:-check}"
if [[ "$lint_command" == "ci" ]]; then
    lint_command="check"
fi

bazel run //tools:buildifier@$lint_command
bazel run //tools:buildifier@lint_warn
