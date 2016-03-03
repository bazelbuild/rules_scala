#!/bin/bash

set -e

bazel build test/... \
  && bazel run test:ScalaBinary \
  && bazel run test:ScalaLibBinary \
  && bazel test test/...

# TODO: this is also broken
#  && bazel run test:JavaBinary \
