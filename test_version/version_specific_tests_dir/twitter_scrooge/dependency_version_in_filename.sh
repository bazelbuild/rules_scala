#!/bin/sh


# this is used by a sh_test to test that a string is NOT
# found in THE NAME OF a file. 
# This is used for instance to check if
# stray jars are not making it onto the classpath

set -x

filename=$1
dependency_version=$2

if grep -q "$dependency_version" <<< $filename; then
  exit 0
else
  echo "ERROR: NOT found $1"
  exit 1
fi
