#!/usr/bin/env bash

set -eou pipefail

bazel run //tools:lint_check
