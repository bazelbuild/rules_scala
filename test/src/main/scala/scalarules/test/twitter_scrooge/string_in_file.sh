#!/bin/sh

# This is used by a sh_test to test whether a string is
# found in a file.
#
# Args:
# . $1: Whether the string should be in the file (accepted values are "true" or "false")
# . $2: String to look for in the file.
# . $3: File to look the string into.
#
# This is used for instance to check if
# stray jars are not making it onto the classpath

should_be_in_file=$1

if [ "$should_be_in_file" != "true" -a "$should_be_in_file" != "false" ]; then
  echo "ERROR: Please use only (\"true\" or \"false\") to specify whether you need the substring to be in the file."
  echo "Refer to test/src/main/scala/scalarules/test/twitter_scrooge/string_in_file.sh for documentation."
  exit 1
fi

if grep -q $2 $3 ; then
  if [ "$should_be_in_file" == "true" ]; then
    exit 0
  else
    echo "ERROR: Found string $2 in $3, when we were expecting not to find it."
    exit 1
  fi
else
  if [ "$should_be_in_file" == "true" ]; then
    echo "ERROR: Not found string $2 in $3, when we were expecting to find it."
    exit 1
  else
    exit 0
  fi
fi
