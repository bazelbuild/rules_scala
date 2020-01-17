#!/usr/bin/env bash

set -e

test_scala_version() {
  SCALA_VERSION=$1

  SCALA_VERSION_SHAS=''
  SCALA_VERSION_SHAS+='"scala_compiler": "'$2'",'
  SCALA_VERSION_SHAS+='"scala_library": "'$3'",'
  SCALA_VERSION_SHAS+='"scala_reflect": "'$4'"'

  cd "${dir}"/test_version

  timestamp=$(date +%s)

  NEW_TEST_DIR="test_${SCALA_VERSION}_${timestamp}"

  cp -r version_specific_tests_dir/ $NEW_TEST_DIR

  sed \
      -e "s/\${scala_version}/$SCALA_VERSION/" \
      -e "s/\${scala_version_shas}/$SCALA_VERSION_SHAS/" \
      WORKSPACE.template >> $NEW_TEST_DIR/WORKSPACE

  cd $NEW_TEST_DIR

  bazel test //...
  RESPONSE_CODE=$?

  cd ..
  rm -rf $NEW_TEST_DIR

  exit $RESPONSE_CODE

}

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# shellcheck source=./test_runner.sh
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

$runner test_scala_version "2.11.12" \
    "3e892546b72ab547cb77de4d840bcfd05c853e73390fed7370a8f19acb0735a0" \
    "0b3d6fd42958ee98715ba2ec5fe221f4ca1e694d7c981b0ae0cd68e97baf6dce" \
    "6ba385b450a6311a15c918cf8688b9af9327c6104f0ecbd35933cfcd3095fe04"

$runner test_scala_version "2.12.10" \
    "cedc3b9c39d215a9a3ffc0cc75a1d784b51e9edc7f13051a1b4ad5ae22cfbc0c" \
    "0a57044d10895f8d3dd66ad4286891f607169d948845ac51e17b4c1cf0ab569d" \
    "56b609e1bab9144fb51525bfa01ccd72028154fc40a58685a1e9adcbe7835730"
