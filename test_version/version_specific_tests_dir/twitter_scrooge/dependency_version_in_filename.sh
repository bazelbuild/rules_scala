#!/bin/sh

# this is used by a sh_test to test that a string is 
# found in THE NAME OF a file. 
# This is used to check if we are resolving the right version of scrooge dependencies.

set -x
filename=$1 # The path to the jar of a specific dependency of scrooge
dependency_version=$2 # The version that we want to match the jar to.
                      # We get this value via `--test_args` in `./test_version.sh`

# We use case here as a POSIX-compilant way of checking for substrings
case "$filename" in
  *$dependency_version*) exit 0 ;;
  *)         echo "ERROR: NOT found $dependency_version in $filename"; exit 1 ;;
esac
