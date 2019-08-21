#!/usr/bin/env bash

set -eou pipefail

./tools/bazel run //tools:buildifier@check
