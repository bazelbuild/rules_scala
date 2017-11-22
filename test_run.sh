#!/bin/bash

set -e

bazel run src/java/io
bazel clean
bazel run src/java/io
