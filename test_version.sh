#!/usr/bin/env bash

set -e

scala_2_11_version="2.11.12"
scala_2_12_version="2.12.14"
scala_2_13_version="2.13.11"

SCALA_VERSION_DEFAULT=$scala_2_11_version

diagnostics_reporter_toolchain="//:diagnostics_reporter_toolchain"
no_diagnostics_reporter_toolchain="//:no_diagnostics_reporter_toolchain"

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
  local SCALA_VERSION=${SCALA_VERSION:-$SCALA_VERSION_DEFAULT}

  local test_command=$1
  local test_dir_prefix=$2
  local test_target=$3

  cd "${dir}"/test_version

  local timestamp=$(date +%s)

  NEW_TEST_DIR="test_${test_dir_prefix}_${timestamp}"

  cp -r $test_target $NEW_TEST_DIR

  sed \
      -e "s%\${twitter_scrooge_repositories}%$TWITTER_SCROOGE_REPOSITORIES%" \
      WORKSPACE.template >> $NEW_TEST_DIR/WORKSPACE

  cd $NEW_TEST_DIR

  ${test_command}
  RESPONSE_CODE=$?

  cd ..
  rm -rf $NEW_TEST_DIR
  
  exit $RESPONSE_CODE
}

test_scala_version() {
  local SCALA_VERSION="$1"

  run_in_test_repo "bazel test //... --repo_env=SCALA_VERSION=${SCALA_VERSION}" "scala_version" "version_specific_tests_dir/"
}

test_reporter() {
  local SCALA_VERSION="$1"
  local SCALA_TOOLCHAIN="$2"

  run_in_test_repo "compilation_should_fail build //... --repo_env=SCALA_VERSION=${SCALA_VERSION} --extra_toolchains=${SCALA_TOOLCHAIN}" "reporter" "test_reporter/"
}

test_twitter_scrooge_versions() {
  local version_under_test=$1

  local TWITTER_SCROOGE_REPOSITORIES_18_6_0='scrooge_repositories(version = "18.6.0")'

  local TWITTER_SCROOGE_REPOSITORIES_21_2_0='scrooge_repositories(version = "21.2.0")'

  if [ "18.6.0" = $version_under_test ]; then
    TWITTER_SCROOGE_REPOSITORIES=$TWITTER_SCROOGE_REPOSITORIES_18_6_0
  elif [ "20.9.0" = $version_under_test ]; then
    TWITTER_SCROOGE_REPOSITORIES=$TWITTER_SCROOGE_REPOSITORIES_20_9_0
  else
    echo "Unknown Twitter Scrooge version given $version_under_test"
  fi

  run_in_test_repo "bazel test //twitter_scrooge/... --test_arg=${version_under_test}" "scrooge_version" "version_specific_tests_dir/"
}

if ! bazel_loc="$(type -p 'bazel')" || [[ -z "$bazel_loc" ]]; then
  export PATH="$(cd "$(dirname "$0")"; pwd)"/tools:$PATH
  echo 'Using ./tools/bazel directly for bazel calls'
fi

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# shellcheck source=./test_runner.sh
. "${dir}"/test/shell/test_runner.sh
runner=$(get_test_runner "${1:-local}")
export USE_BAZEL_VERSION=${USE_BAZEL_VERSION:-$(cat $dir/.bazelversion)}

#TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_11_version}"
#TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_12_version}"
TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_13_version}"

TEST_TIMEOUT=15 $runner test_twitter_scrooge_versions "18.6.0"
TEST_TIMEOUT=15 $runner test_twitter_scrooge_versions "21.2.0"

TEST_TIMEOUT=15 $runner test_reporter "${scala_2_11_version}" "${no_diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_2_12_version}" "${no_diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_2_13_version}" "${no_diagnostics_reporter_toolchain}"

TEST_TIMEOUT=15 $runner test_reporter "${scala_2_11_version}" "${diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_2_12_version}" "${diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_2_13_version}" "${diagnostics_reporter_toolchain}"
