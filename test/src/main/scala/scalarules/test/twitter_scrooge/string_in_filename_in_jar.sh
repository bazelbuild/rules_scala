#!/bin/sh

# This is used by a sh_test to test whether a string is
# found in a name of a file inside a jar file.
#
# Args:
# . $1: Whether the string should be in the name of a file (accepted values are "true" or "false").
# . $2: Path to jar file relative to root directory.
# . $3: String to look for in the name of files in the jar file.
# . $4: File - is used to find the path to root directory of the given target.
#
# This is used for instance to check if
# a given jar has a file with a given name.

should_be_in_file=$1

if test "$should_be_in_file" != "true" -a "$should_be_in_file" != "false" ; then
  echo "ERROR: Please use only (\"true\" or \"false\") to specify whether you need the substring to be in the file."
  echo "Refer to test/src/main/scala/scalarules/test/twitter_scrooge/string_in_jar_file.sh for documentation."
  exit 1
fi

dir="$(dirname $4)"
jar_file="$dir/$2"
jar tf ${jar_file} | grep -q $3
file_is_in_jar=$?

if [ $file_is_in_jar -eq 0 ] ; then
  if test "$should_be_in_file" = "true" ; then
    exit 0
  else
    echo "ERROR: Found file $3 in ${jar_file}, when we were expecting not to find it."
    exit 1
  fi
else
  if test "$should_be_in_file" = "true" ; then
    echo "ERROR: Not found file $3 in ${jar_file}, when we were expecting to find it."
    exit 1
  else
    exit 0
  fi
fi
