#!/usr/bin/env bash

set -e

test_scala_version() {
  SCALA_VERSION=$1
  bazel test --test_output=errors //third_party/... --repo_env=SCALA_VERSION=${SCALA_VERSION}
}

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
test_dir=$dir/test/shell
# shellcheck source=./test_runner.sh
. "${test_dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")


# Latest version of each major version
$runner test_scala_version "3.6.3" # Latest Next version
$runner test_scala_version "3.3.5" # Latest LTS version
$runner test_scala_version "3.1.3" # First supported major for Scala 3, max supported JDK=18
$runner test_scala_version "2.13.16"
$runner test_scala_version "2.12.20"

# Tests for other versions should be placed in dangerous_test_thirdparty_version.sh 
# However that script is outdated and uses only default Scala version for each minor
