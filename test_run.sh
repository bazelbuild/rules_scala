#!/bin/bash

set -e

bazel build test/... \
  && bazel run test:ScalaBinary \
  && bazel run test:ScalaLibBinary \
  && bazel run test:JavaBinary \
  && bazel test test/... \
  && (find -L ./bazel-testlogs -iname "*.scala" | xargs -n1 xmllint > /dev/null) \
  && echo "all good"
