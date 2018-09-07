#!/bin/sh


# this is used by a sh_test to test that a string is NOT
# found in a file. This is used for instance to check if
# stray jars are not making it onto the classpath

if grep -q $1 $2 ; then
  echo "ERROR: found $1"
  exit 1
else
  exit 0
fi
