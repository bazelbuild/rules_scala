#!/bin/bash

set -e

bazel build test/... \
  && bazel run test:ScalaBinary \
  && bazel run test:ScalaLibBinary \
  && bazel run test:JavaBinary \
  && bazel test test/...
