#!/bin/sh


# this is used by a sh_test to test that a string is NOT
# found in THE NAME OF a file. 
# This is used to check if we are resolving the right version of scrooge_core

set -x
filename=$1
dependency_version=$2

# We use case here as a POSIX-compilant way of checking for substrings
case "$filename" in
  *$dependency_version*) exit 0 ;;
  *)         echo "ERROR: NOT found $dependency_version in $filename"; exit 1 ;;
esac
