#!/usr/bin/env bash

echoerr() {
  echo "$@" 1>&2;
}

assert() {
  $@ || (echo "FAILED: $@"; exit 1)
}

contains() {
  grep $@
}

set -e

TARGET="MixJavaScalaLib"

assert contains "test/${TARGET}.jar" $1
assert contains "test/${TARGET}_java.jar" $1
