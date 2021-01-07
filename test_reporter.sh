#!/usr/bin/env bash

set -e

scala_2_11_version="2.11.12"
scala_2_12_version="2.12.11"
scala_2_13_version="2.13.3"

diagnostics_reporter_toolchain="diagnostics_reporter_toolchain"
no_diagnostics_reporter_toolchain="no_diagnostics_reporter_toolchain"


compilation_should_fail() {
  # runs the tests locally
  set +e
  TEST_ARG=$@
  DUMMY=$(bazel $TEST_ARG)
  RESPONSE_CODE=$?
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo -e "${RED} \"bazel $TEST_ARG\" should have failed but passed. $NC"
    return -1
  else
    return 0
  fi
}

run_in_test_repo() {
  local SCALA_VERSION=${SCALA_VERSION}
  local SCALA_TOOLCHAIN=${SCALA_TOOLCHAIN}

  local test_command=$1
  local test_dir_prefix=$2

  cd "${dir}"

  local timestamp=$(date +%s)

  NEW_TEST_DIR="test_${test_dir_prefix}_${timestamp}"

  cp -r test_reporter/ "$NEW_TEST_DIR"

  sed \
      -e "s/\${scala_version}/$SCALA_VERSION/" \
      -e "s/\${testing_toolchain}/$SCALA_TOOLCHAIN/" \
      test_reporter/WORKSPACE.template >> "$NEW_TEST_DIR"/WORKSPACE

  cd "$NEW_TEST_DIR"

  compilation_should_fail ${test_command}
  RESPONSE_CODE=$?

  cd ..
  rm -rf "$NEW_TEST_DIR"

  exit $RESPONSE_CODE
}

test_scala_version() {
  local SCALA_VERSION="$1"
  local SCALA_TOOLCHAIN="$2"

  run_in_test_repo "build //..." "scala_reporter"
}

if ! bazel_loc="$(type -p 'bazel')" || [[ -z "$bazel_loc" ]]; then
  export PATH="$(cd "$(dirname "$0")"; pwd)"/tools:$PATH
  echo 'Using ./tools/bazel directly for bazel calls'
fi

# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test/shell/test_runner.sh
runner=$(get_test_runner "${1:-local}")
export USE_BAZEL_VERSION=${USE_BAZEL_VERSION:-$(cat "$dir"/.bazelversion)}

TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_11_version}" "${no_diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_12_version}" "${no_diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_13_version}" "${no_diagnostics_reporter_toolchain}"

#TODO: Uncomment this out after diagnostics reporter properly reports errors for scala 2.11
#TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_11_version}" "${diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_12_version}" "${diagnostics_reporter_toolchain}"
TESTs_TIMEOUT=15 $runner test_scala_version "${scala_2_13_version}" "${diagnostics_reporter_toolchain}"
