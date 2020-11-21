#!/usr/bin/env bash

set -e

scala_2_11_version="2.11.12"
scala_2_12_version="2.12.11"

SCALA_VERSION_DEFAULT=$scala_2_11_version
SCALA_VERSION_SHAS_DEFAULT=$scala_2_11_shas
TWITTER_SCROOGE_ARTIFACTS='twitter_scrooge_artifacts={}'

run_in_test_repo() {
  local SCALA_VERSION=${SCALA_VERSION:-$SCALA_VERSION_DEFAULT}

  local test_command=$1
  local test_dir_prefix=$2

  cd "${dir}"/test_version

  local timestamp=$(date +%s)

  NEW_TEST_DIR="test_${test_dir_prefix}_${timestamp}"

  cp -r version_specific_tests_dir/ $NEW_TEST_DIR

  sed \
      -e "s/\${scala_version}/$SCALA_VERSION/" \
      -e "s%\${twitter_scrooge_artifacts}%$TWITTER_SCROOGE_ARTIFACTS%" \
      WORKSPACE.template >> $NEW_TEST_DIR/WORKSPACE

  cd $NEW_TEST_DIR

  bazel ${test_command}
  RESPONSE_CODE=$?

  cd ..
  rm -rf $NEW_TEST_DIR

  exit $RESPONSE_CODE
}

test_scala_version() {
  local SCALA_VERSION="$1"
  if [[ $SCALA_VERSION == $scala_2_12_version ]]; then
    local SCALA_VERSION_SHAS=$scala_2_12_shas
  else
    local SCALA_VERSION_SHAS=$scala_2_11_shas
  fi

  run_in_test_repo "test //..." "scala_version"
}

test_twitter_scrooge_versions() {
  local version_under_test=$1

  local TWITTER_SCROOGE_ARTIFACTS_18_6_0='twitter_scrooge_artifacts={ \
    "io_bazel_rules_scala_scrooge_core": {\
        "artifact": "com.twitter:scrooge-core_2.11:18.6.0",\
        "sha256": "00351f73b555d61cfe7320ef3b1367a9641e694cfb8dfa8a733cfcf49df872e8",\
    },\
    "io_bazel_rules_scala_scrooge_generator": {\
        "artifact": "com.twitter:scrooge-generator_2.11:18.6.0",\
        "sha256": "0f0027e815e67985895a6f3caa137f02366ceeea4966498f34fb82cabb11dee6",\
        "runtime_deps": [\
            "@io_bazel_rules_scala_guava",\
            "@io_bazel_rules_scala_mustache",\
        ],\
    },\
    "io_bazel_rules_scala_util_core": {\
        "artifact": "com.twitter:util-core_2.11:18.6.0",\
        "sha256": "5336da4846dfc3db8ffe5ae076be1021828cfee35aa17bda9af461e203cf265c",\
    },\
    "io_bazel_rules_scala_util_logging": {\
        "artifact": "com.twitter:util-logging_2.11:18.6.0",\
        "sha256": "73ddd61cedabd4dab82b30e6c52c1be6c692b063b8ba310d716ead9e3b4e9267",\
    },\
}'

  local TWITTER_SCROOGE_ARTIFACTS_20_9_0='twitter_scrooge_artifacts={ \
    "io_bazel_rules_scala_scrooge_core": {\
        "artifact": "com.twitter:scrooge-core_2.11:20.9.0",\
        "sha256": "de21b01d356bfcae4d184ed877dac21753ae9c29e11d934f007789ec7b07961f",\
    },\
    "io_bazel_rules_scala_scrooge_generator": {\
        "artifact": "com.twitter:scrooge-generator_2.11:20.9.0",\
        "sha256": "1b027bb10604d34b0790a4936d9b5c95bf0a0ccac522521d9c7e898b87d16c79",\
        "runtime_deps": [\
            "@io_bazel_rules_scala_guava",\
            "@io_bazel_rules_scala_mustache",\
        ],\
    },\
    "io_bazel_rules_scala_util_core": {\
        "artifact": "com.twitter:util-core_2.11:20.9.0",\
        "sha256": "59955ecc258bcdd5de0199e289548717a794c7a1020f34ebef69a5f2cb36e127",\
    },\
    "io_bazel_rules_scala_util_logging": {\
        "artifact": "com.twitter:util-logging_2.11:20.9.0",\
        "sha256": "32afd3278232cf504e77a7833eef812bb4e2ae16f6f524910896cf844e223eef",\
    },\
}'

  if [ "18.6.0" = $version_under_test ]; then
    TWITTER_SCROOGE_ARTIFACTS=$TWITTER_SCROOGE_ARTIFACTS_18_6_0
  elif [ "20.9.0" = $version_under_test ]; then
    TWITTER_SCROOGE_ARTIFACTS=$TWITTER_SCROOGE_ARTIFACTS_20_9_0
  else
    echo "Unknown Twitter Scrooge version given $version_under_test"
  fi

  run_in_test_repo "test //twitter_scrooge/... --test_arg=${version_under_test}" "scrooge_version"
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

TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_11_version}"
TEST_TIMEOUT=15 $runner test_scala_version "${scala_2_12_version}"

TEST_TIMEOUT=15 $runner test_twitter_scrooge_versions "18.6.0"
TEST_TIMEOUT=15 $runner test_twitter_scrooge_versions "20.9.0"
