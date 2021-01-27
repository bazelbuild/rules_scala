#!/usr/bin/env bash

set -eou pipefail

bazel run //tools:buildifier@fix

bazel run //tools:buildifier@lint_fix
