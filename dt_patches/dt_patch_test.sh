#!/usr/bin/env bash

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'

run_test_local() {
  # runs the tests locally
  set +e
  SECONDS=0
  TEST_ARG=$@
  echo "running test $TEST_ARG"
  RES=$($TEST_ARG 2>&1)
  RESPONSE_CODE=$?
  DURATION=$SECONDS
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo -e "${GREEN} Test \"$TEST_ARG\" successful ($DURATION sec) $NC"
  else
    echo $RES
    echo -e "${RED} Test \"$TEST_ARG\" failed $NC ($DURATION sec) $NC"
    return $RESPONSE_CODE
  fi
}

run_in_test_repo() {
  local test_command=$1
  local test_repo=$2

  cd "${dir}/${test_repo}" || exit 1 
  ${test_command}
  RESPONSE_CODE=$?

  bazel shutdown
  
  cd ../..

  return $RESPONSE_CODE
}

test_compiler_patch() {
  local SCALA_VERSION="$1"

  run_in_test_repo "bazel build //... --repo_env=SCALA_VERSION=${SCALA_VERSION} //..." "test_dt_patches"
}

test_compiler_srcjar() {
  set -o pipefail
  local SCALA_VERSION="$1"

  run_in_test_repo "bazel build //... --repo_env=SCALA_VERSION=${SCALA_VERSION} //..." "test_dt_patches_user_srcjar" 2>&1 | (! grep "canonical reproducible")
}

test_compiler_srcjar_nonhermetic() {
  set -o pipefail
  local SCALA_VERSION="$1"

  run_in_test_repo "bazel build //... --repo_env=SCALA_VERSION=${SCALA_VERSION} //..." "test_dt_patches_user_srcjar" 2>&1 | grep "canonical reproducible"
}

test_compiler_srcjar_error() {
  local SCALA_VERSION="$1"
  local EXPECTED_ERROR="scala_compiler_srcjar invalid"

  run_in_test_repo "bazel build //... --repo_env=SCALA_VERSION=${SCALA_VERSION} //..." "test_dt_patches_user_srcjar" 2>&1 | grep "$EXPECTED_ERROR"
}

run_test_local test_compiler_patch 2.12.1


#run_test_local test_compiler_patch 2.11.0
#run_test_local test_compiler_patch 2.11.1
#run_test_local test_compiler_patch 2.11.2
#run_test_local test_compiler_patch 2.11.3
#run_test_local test_compiler_patch 2.11.4
#run_test_local test_compiler_patch 2.11.5
#run_test_local test_compiler_patch 2.11.6
#run_test_local test_compiler_patch 2.11.7
#run_test_local test_compiler_patch 2.11.8
#run_test_local test_compiler_patch 2.11.9
#run_test_local test_compiler_patch 2.11.10
#run_test_local test_compiler_patch 2.11.11
run_test_local test_compiler_patch 2.11.12

#run_test_local test_compiler_patch 2.12.0
run_test_local test_compiler_patch 2.12.1
run_test_local test_compiler_patch 2.12.2
run_test_local test_compiler_patch 2.12.3
run_test_local test_compiler_patch 2.12.4
run_test_local test_compiler_patch 2.12.5
run_test_local test_compiler_patch 2.12.6
run_test_local test_compiler_patch 2.12.7
run_test_local test_compiler_patch 2.12.8
run_test_local test_compiler_patch 2.12.9
run_test_local test_compiler_patch 2.12.10
run_test_local test_compiler_patch 2.12.11
run_test_local test_compiler_patch 2.12.12
run_test_local test_compiler_patch 2.12.13
run_test_local test_compiler_patch 2.12.14
run_test_local test_compiler_patch 2.12.15
run_test_local test_compiler_patch 2.12.16
run_test_local test_compiler_patch 2.12.17
run_test_local test_compiler_patch 2.12.18
run_test_local test_compiler_patch 2.12.19

run_test_local test_compiler_patch 2.13.0
run_test_local test_compiler_patch 2.13.1
run_test_local test_compiler_patch 2.13.2
run_test_local test_compiler_patch 2.13.3
run_test_local test_compiler_patch 2.13.4
run_test_local test_compiler_patch 2.13.5
run_test_local test_compiler_patch 2.13.6
run_test_local test_compiler_patch 2.13.7
run_test_local test_compiler_patch 2.13.8
run_test_local test_compiler_patch 2.13.10
run_test_local test_compiler_patch 2.13.11
run_test_local test_compiler_patch 2.13.12
run_test_local test_compiler_patch 2.13.14

run_test_local test_compiler_srcjar_error 2.12.11
run_test_local test_compiler_srcjar_error 2.12.12
run_test_local test_compiler_srcjar_error 2.12.13
# These tests are semi-stateful, if two tests are run sequentially with the
# same Scala version, the DEBUG message about a canonical reproducible form
# that we grep for will only be outputted the first time (on Bazel >= 6).
run_test_local test_compiler_srcjar 2.12.14
run_test_local test_compiler_srcjar 2.12.15
run_test_local test_compiler_srcjar 2.12.16
run_test_local test_compiler_srcjar_nonhermetic 2.12.17
run_test_local test_compiler_srcjar_nonhermetic 2.12.18
run_test_local test_compiler_srcjar_nonhermetic 2.12.19

run_test_local test_compiler_srcjar_nonhermetic 2.13.11
run_test_local test_compiler_srcjar_nonhermetic 2.13.12
run_test_local test_compiler_srcjar_nonhermetic 2.13.14