#!/usr/bin/env bash

# This test is dangerous in that it modifies the root rules_scala
# WORKSPACE file. It attempts to restore the existing WORKSPACE file
# but there are risks that it may not be successful.

# Hence when running this test one should be sure that they do not
# have changes in the WORKSPACE file which they cannot recover
# from if the file gets lost.

# Note that due to performance constraints this is purposely not
# part of CI but when modifying the dependency_analyzer plugin,
# this should be run to ensure no regressions.

set -e

replace_workspace() {
  sed -i '' \
      -e "s|scala_config(.*)|$1|" \
      $dir/WORKSPACE
}

test_scala_version() {
  SCALA_VERSION=$1

  cp $dir/WORKSPACE $dir/WORKSPACE.bak
  replace_workspace "scala_config(scala_version='$SCALA_VERSION')"

  bazel test //third_party/...
  RESPONSE_CODE=$?
  # Restore old behavior
  rm $dir/WORKSPACE
  mv $dir/WORKSPACE.bak $dir/WORKSPACE
  exit $RESPONSE_CODE

}

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
test_dir=$dir/test/shell
# shellcheck source=./test_runner.sh
. "${test_dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")


# Latest versions of each major version
$runner test_scala_version "2.12.10"
$runner test_scala_version "2.11.12"
# Earliest functioning versions of each major version
$runner test_scala_version "2.12.0"


# Note: 2.11.0-2.11.8 do not work due to an error unrelated to the plugin
# Error is that argument -Ypartial-unification is invalid
# Hence we start with 2.11.9.
$runner test_scala_version "2.11.9"

# Intermediate versions of 2.12.x
$runner test_scala_version "2.12.1"
$runner test_scala_version "2.12.2"
$runner test_scala_version "2.12.3"
$runner test_scala_version "2.12.4"
$runner test_scala_version "2.12.5"
$runner test_scala_version "2.12.6"
$runner test_scala_version "2.12.7"
$runner test_scala_version "2.12.8"
$runner test_scala_version "2.12.9"

# Intermediate versions of 2.11.x
$runner test_scala_version "2.11.10"
$runner test_scala_version "2.11.11"
