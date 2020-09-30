#!/usr/bin/env bash

set -e

scala_2_11_version="2.11.12"
scala_2_11_shas='\
  "scala_compiler": "3e892546b72ab547cb77de4d840bcfd05c853e73390fed7370a8f19acb0735a0", \
  "scala_library": "0b3d6fd42958ee98715ba2ec5fe221f4ca1e694d7c981b0ae0cd68e97baf6dce", \
  "scala_reflect": "6ba385b450a6311a15c918cf8688b9af9327c6104f0ecbd35933cfcd3095fe04" \
'
scala_2_12_version="2.12.10"
scala_2_12_shas='\
  "scala_compiler": "cedc3b9c39d215a9a3ffc0cc75a1d784b51e9edc7f13051a1b4ad5ae22cfbc0c", \
  "scala_library": "0a57044d10895f8d3dd66ad4286891f607169d948845ac51e17b4c1cf0ab569d", \
  "scala_reflect": "56b609e1bab9144fb51525bfa01ccd72028154fc40a58685a1e9adcbe7835730" \
'

SCALA_VERSION_DEFAULT=$scala_2_11_version
SCALA_VERSION_SHAS_DEFAULT=$scala_2_11_shas
TWITTER_SCROOGE_VERSION_SHAS_DEFAULT=''
TWITTER_SCROOGE_EXTRA_IMPORTS_DEFAULT=''
TWITTER_SCROOGE_BINDINGS_DEFAULT='twitter_scrooge(scala_version)'

run_in_test_repo() {
  local SCALA_VERSION=${SCALA_VERSION:-$SCALA_VERSION_DEFAULT}
  local SCALA_VERSION_SHAS=${SCALA_VERSION_SHAS:-$SCALA_VERSION_SHAS_DEFAULT}
  local TWITTER_SCROOGE_BINDINGS=${TWITTER_SCROOGE_BINDINGS:-$TWITTER_SCROOGE_BINDINGS_DEFAULT}
  local TWITTER_SCROOGE_EXTRA_IMPORTS=${TWITTER_SCROOGE_EXTRA_IMPORTS:-$TWITTER_SCROOGE_EXTRA_IMPORTS_DEFAULT}
  local TWITTER_SCROOGE_VERSION_SHAS=${TWITTER_SCROOGE_VERSION_SHAS:-$TWITTER_SCROOGE_VERSION_SHAS_DEFAULT}

  local test_command=$1
  local test_dir_prefix=$2

  cd "${dir}"/test_version

  local timestamp=$(date +%s)

  NEW_TEST_DIR="test_${test_dir_prefix}_${timestamp}"

  cp -r version_specific_tests_dir/ $NEW_TEST_DIR

  sed \
      -e "s/\${scala_version}/$SCALA_VERSION/" \
      -e "s%\${scala_version_shas}%$SCALA_VERSION_SHAS%" \
      -e "s%\${twitter_scrooge_bindings}%$TWITTER_SCROOGE_BINDINGS%" \
      -e "s%\${twitter_scrooge_extra_imports}%$TWITTER_SCROOGE_EXTRA_IMPORTS%" \
      -e "s%\${twitter_scrooge_version_shas}%$TWITTER_SCROOGE_VERSION_SHAS%" \
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

  local TWITTER_SCROOGE_VERSION_SHAS='twitter_scrooge_version_shas= {\
  "18.6.0": { \
    "scrooge-generator": "0f0027e815e67985895a6f3caa137f02366ceeea4966498f34fb82cabb11dee6", \
    "scrooge-core": "00351f73b555d61cfe7320ef3b1367a9641e694cfb8dfa8a733cfcf49df872e8", \
    "util-core": "5336da4846dfc3db8ffe5ae076be1021828cfee35aa17bda9af461e203cf265c", \
    "util-logging": "73ddd61cedabd4dab82b30e6c52c1be6c692b063b8ba310d716ead9e3b4e9267" \
  }, \
  "20.5.0": { \
    "scrooge-generator": "a4cf7dd773e8c2ee0ccad52be1ebd4ae8a9defcbc9be28e370e44a46a34a005a", \
    "scrooge-core": "b1aa0f3b9f10287644f1edc47b79a67b287656d97fbd157a806d69c82b27e21d", \
    "util-core": "253cc631d3766e978bafd60dcee6976f7cf46d80106882c7b55b969ab14e3d7c", \
    "util-logging": "77782dad82e4066a2b8aa1aa6c07c8c2d111f65365833a88592e303464a98654" \
  } \
}'

  local TWITTER_SCROOGE_EXTRA_IMPORTS="load(\"//twitter_scrooge:twitter_scrooge_bindings.bzl\", \"twitter_scrooge_with_custom_dep_version\")"
  local TWITTER_SCROOGE_BINDINGS="twitter_scrooge_with_custom_dep_version(\"${version_under_test}\", scala_version, twitter_scrooge_version_shas)"

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
$runner test_scala_version "${scala_2_11_version}"
$runner test_scala_version "${scala_2_12_version}"

$runner test_twitter_scrooge_versions "18.6.0"
$runner test_twitter_scrooge_versions "20.5.0"
