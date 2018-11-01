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

assert contains "test/${2}.jar" $1
assert contains "test/${2}_java.jar" $1
