#!/usr/bin/env bash

set -euo pipefail

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# shellcheck source=./test_runner.sh
. "${dir}"/../test/shell/test_runner.sh
. "${dir}"/../test/shell/test_helper.sh
runner="$(get_test_runner "${1:-local}")"

run_in_test_repo() {
  local test_repo="$1"
  local test_command=("${@:2}")
  local response_code=0

  cd "${dir}/${test_repo}" || return 1
  "${test_command[@]}" || response_code=$?

  bazel shutdown
  cd ../..
  return $response_code
}

test_compiler_patch() {
  local SCALA_VERSION="$1"

  run_in_test_repo \
    test_dt_patches \
    bazel build "--repo_env=SCALA_VERSION=${SCALA_VERSION}" //...
}

test_compiler_srcjar() {
  set -o pipefail
  local SCALA_VERSION="$1"

  run_in_test_repo \
    test_dt_patches_user_srcjar \
    bazel build "--repo_env=SCALA_VERSION=${SCALA_VERSION}" //... 2>&1 |
    (! grep "canonical reproducible")
}

test_compiler_srcjar_nonhermetic() {
  set -o pipefail
  local SCALA_VERSION="$1"

  run_in_test_repo \
    test_dt_patches_user_srcjar \
    bazel build "--repo_env=SCALA_VERSION=${SCALA_VERSION}" //... 2>&1 |
    grep 'canonical reproducible'
}

test_compiler_srcjar_error() {
  local SCALA_VERSION="$1"

  run_in_test_repo \
    test_dt_patches_user_srcjar \
    action_should_fail_with_message \
    'scala_compiler_srcjar invalid' \
    build "--repo_env=SCALA_VERSION=${SCALA_VERSION}" //...
}

#$runner test_compiler_patch 2.11.0
#$runner test_compiler_patch 2.11.1
#$runner test_compiler_patch 2.11.2
#$runner test_compiler_patch 2.11.3
#$runner test_compiler_patch 2.11.4
#$runner test_compiler_patch 2.11.5
#$runner test_compiler_patch 2.11.6
#$runner test_compiler_patch 2.11.7
#$runner test_compiler_patch 2.11.8
#$runner test_compiler_patch 2.11.9
#$runner test_compiler_patch 2.11.10
#$runner test_compiler_patch 2.11.11
$runner test_compiler_patch 2.11.12

#$runner test_compiler_patch 2.12.0
$runner test_compiler_patch 2.12.1
$runner test_compiler_patch 2.12.2
$runner test_compiler_patch 2.12.3
$runner test_compiler_patch 2.12.4
$runner test_compiler_patch 2.12.5
$runner test_compiler_patch 2.12.6
$runner test_compiler_patch 2.12.7
$runner test_compiler_patch 2.12.8
$runner test_compiler_patch 2.12.9
$runner test_compiler_patch 2.12.10
$runner test_compiler_patch 2.12.11
$runner test_compiler_patch 2.12.12
$runner test_compiler_patch 2.12.13
$runner test_compiler_patch 2.12.14
$runner test_compiler_patch 2.12.15
$runner test_compiler_patch 2.12.16
$runner test_compiler_patch 2.12.17
$runner test_compiler_patch 2.12.18
$runner test_compiler_patch 2.12.19
$runner test_compiler_patch 2.12.20

$runner test_compiler_patch 2.13.0
$runner test_compiler_patch 2.13.1
$runner test_compiler_patch 2.13.2
$runner test_compiler_patch 2.13.3
$runner test_compiler_patch 2.13.4
$runner test_compiler_patch 2.13.5
$runner test_compiler_patch 2.13.6
$runner test_compiler_patch 2.13.7
$runner test_compiler_patch 2.13.8
$runner test_compiler_patch 2.13.10
$runner test_compiler_patch 2.13.11
$runner test_compiler_patch 2.13.12
$runner test_compiler_patch 2.13.14
$runner test_compiler_patch 2.13.15
$runner test_compiler_patch 2.13.16

$runner test_compiler_patch 3.1.0 # Minimal supported version
$runner test_compiler_patch 3.1.3
$runner test_compiler_patch 3.2.2
$runner test_compiler_patch 3.3.6
$runner test_compiler_patch 3.4.3
$runner test_compiler_patch 3.5.2
$runner test_compiler_patch 3.6.4
$runner test_compiler_patch 3.7.1

$runner test_compiler_srcjar_error 2.12.11
$runner test_compiler_srcjar_error 2.12.12
$runner test_compiler_srcjar_error 2.12.13

# These tests are semi-stateful, if two tests are run sequentially with the
# same Scala version, the DEBUG message about a canonical reproducible form
# that we grep for will only be outputted the first time (on Bazel >= 6).
# So we clean the repo first to ensure consistency.

run_in_test_repo 'test_dt_patches_user_srcjar' bazel clean --expunge

$runner test_compiler_srcjar 2.12.14
$runner test_compiler_srcjar 2.12.15
$runner test_compiler_srcjar 2.12.16
$runner test_compiler_srcjar_nonhermetic 2.12.17
$runner test_compiler_srcjar_nonhermetic 2.12.18
$runner test_compiler_srcjar_nonhermetic 2.12.19
$runner test_compiler_srcjar_nonhermetic 2.12.20

$runner test_compiler_srcjar_nonhermetic 2.13.11
$runner test_compiler_srcjar_nonhermetic 2.13.12
$runner test_compiler_srcjar_nonhermetic 2.13.14
$runner test_compiler_srcjar_nonhermetic 2.13.15
$runner test_compiler_srcjar_nonhermetic 2.13.16

$runner test_compiler_srcjar 3.1.3
$runner test_compiler_srcjar 3.2.2
$runner test_compiler_srcjar_nonhermetic 3.3.6
$runner test_compiler_srcjar 3.4.3
$runner test_compiler_srcjar_nonhermetic 3.5.2
$runner test_compiler_srcjar_nonhermetic 3.6.4
$runner test_compiler_srcjar_nonhermetic 3.7.1
