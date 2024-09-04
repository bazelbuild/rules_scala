#!/usr/bin/env bash

set -e

scala_2_11_version="2.11.12"
scala_2_12_version="2.12.19"
scala_2_13_version="2.13.14"
scala_3_version="3.3.3"

SCALA_VERSION_DEFAULT=$scala_2_11_version

diagnostics_reporter_toolchain="//:diagnostics_reporter_toolchain"
diagnostics_reporter_and_semanticdb_toolchain="//:diagnostics_reporter_and_semanticdb_toolchain"
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

  local scrooge_ws=""

  if [[ -n "$TWITTER_SCROOGE_VERSION" ]]; then
    local version_param="version = \"$TWITTER_SCROOGE_VERSION\""
    scrooge_ws="scrooge_repositories($version_param)"
  fi

  sed -e "s%\${twitter_scrooge_repositories}%${scrooge_ws}\n%" \
      WORKSPACE.template >> $NEW_TEST_DIR/WORKSPACE
  cp ../.bazel{rc,version} $NEW_TEST_DIR/

  cd $NEW_TEST_DIR

  ${test_command}
  RESPONSE_CODE=$?

  #make sure bazel still not running for this workspace
  bazel shutdown

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

test_diagnostic_proto_files() {
  local SCALA_VERSION="$1"
  local SCALA_TOOLCHAIN="$2"

  compilation_should_fail build --build_event_publish_all_actions -k --repo_env=SCALA_VERSION=${SCALA_VERSION} --extra_toolchains=${SCALA_TOOLCHAIN} //test_expect_failure/diagnostics_reporter:all
  diagnostics_output="$(bazel info bazel-bin)/test_expect_failure/diagnostics_reporter"
  bazel run --repo_env=SCALA_VERSION=${SCALA_VERSION} //test/diagnostics_reporter:diagnostics_reporter_test "$diagnostics_output"
}

test_twitter_scrooge_versions() {
  local TWITTER_SCROOGE_VERSION="$1"

  case "$TWITTER_SCROOGE_VERSION" in
  18.6.0|20.9.0)
    ;;
  *)
    echo "Unknown Twitter Scrooge version given $TWITTER_SCROOGE_VERSION"
    ;;
  esac

  run_in_test_repo \
    "bazel test //twitter_scrooge/... --test_arg=${TWITTER_SCROOGE_VERSION}" \
    "scrooge_version" \
    "version_specific_tests_dir/"
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

# TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_11_version}"
# TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_12_version}"
# TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_13_version}"

# TEST_TIMEOUT=15 $runner test_twitter_scrooge_versions "18.6.0"
# TEST_TIMEOUT=15 $runner test_twitter_scrooge_versions "21.2.0"

# TEST_TIMEOUT=15 $runner test_reporter "${scala_2_11_version}" "${no_diagnostics_reporter_toolchain}"
# TEST_TIMEOUT=15 $runner test_reporter "${scala_2_12_version}" "${no_diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_2_13_version}" "${no_diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_3_version}"    "${no_diagnostics_reporter_toolchain}"

# TEST_TIMEOUT=15 $runner test_reporter "${scala_2_11_version}" "${diagnostics_reporter_toolchain}"
# TEST_TIMEOUT=15 $runner test_reporter "${scala_2_12_version}" "${diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_2_13_version}" "${diagnostics_reporter_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_3_version}"    "${diagnostics_reporter_toolchain}"

# TEST_TIMEOUT=15 $runner test_reporter "${scala_2_11_version}" "${diagnostics_reporter_and_semanticdb_toolchain}"
# TEST_TIMEOUT=15 $runner test_reporter "${scala_2_12_version}" "${diagnostics_reporter_and_semanticdb_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_2_13_version}" "${diagnostics_reporter_and_semanticdb_toolchain}"
TEST_TIMEOUT=15 $runner test_reporter "${scala_3_version}"    "${diagnostics_reporter_and_semanticdb_toolchain}"

TEST_TIMEOUT=15 $runner test_diagnostic_proto_files "${scala_2_12_version}" //test_expect_failure/diagnostics_reporter:diagnostics_reporter_toolchain
TEST_TIMEOUT=15 $runner test_diagnostic_proto_files "${scala_2_13_version}" //test_expect_failure/diagnostics_reporter:diagnostics_reporter_toolchain
TEST_TIMEOUT=15 $runner test_diagnostic_proto_files "${scala_3_version}"    //test_expect_failure/diagnostics_reporter:diagnostics_reporter_toolchain 

TEST_TIMEOUT=15 $runner test_diagnostic_proto_files "${scala_2_12_version}" //test_expect_failure/diagnostics_reporter:diagnostics_reporter_and_semanticdb_toolchain
TEST_TIMEOUT=15 $runner test_diagnostic_proto_files "${scala_2_13_version}" //test_expect_failure/diagnostics_reporter:diagnostics_reporter_and_semanticdb_toolchain
TEST_TIMEOUT=15 $runner test_diagnostic_proto_files "${scala_3_version}"    //test_expect_failure/diagnostics_reporter:diagnostics_reporter_and_semanticdb_toolchain
