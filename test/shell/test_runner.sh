#!/usr/bin/env bash
#
# Test runner functions for rules_scala integration tests.

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

run_test_ci() {
  # spawns the test to new process
  local TEST_ARG=$@
  local log_file=output_$$.log
  echo "running test $TEST_ARG"
  eval $TEST_ARG &>$log_file &
  local test_pid=$!

  SECONDS=0
  test_pulse_printer "$test_pid" "${TEST_TIMEOUT:-60}" $TEST_ARG &

  local pulse_printer_pid=$!
  local result

  {
    wait $test_pid 2>/dev/null
    result=$?
    kill $pulse_printer_pid && wait $pulse_printer_pid 2>/dev/null || true
  } || return 1

  local DURATION=$SECONDS
  if [ $result -eq 0 ]; then
    echo -e "\n${GREEN}Test \"$TEST_ARG\" successful ($DURATION sec) $NC"
  else
    echo -e "\nLog:\n"
    cat $log_file
    echo -e "\n${RED}Test \"$TEST_ARG\" failed $NC ($DURATION sec) $NC"
  fi
  return $result
}

test_pulse_printer() {
  # makes sure something is printed to stdout while test is running
  local test_pid="$1"
  shift
  local timeout="$1" # in minutes
  shift
  local count=0

  # clear the line
  echo -e "\n"

  while [ $count -lt $timeout ]; do
    count=$(($count + 1))
    echo -ne "Still running: \"$@\"\r"
    sleep 60
  done

  echo -e "\n${RED}Timeout (${timeout} minutes) reached. Terminating \"$@\"${NC}\n"
  kill -9 $test_pid
}

run_test_local() {
  # runs the tests locally
  set +e
  local TEST_ARG=$@
  local RES=''

  # This allows us to run a single test case with full Bazel output without
  # having to search for it and recreate its command line.
  if [[ -n "$RULES_SCALA_TEST_ONLY" &&
        "$TEST_ARG" != "$RULES_SCALA_TEST_ONLY" ]]; then
    return
  fi

  echo "running test $TEST_ARG"
  SECONDS=0

  if [[ -n "$RULES_SCALA_TEST_VERBOSE" || -n "$RULES_SCALA_TEST_ONLY" ]]; then
    $TEST_ARG
  else
    RES="$($TEST_ARG 2>&1)"
  fi

  local RESPONSE_CODE="$?"
  local DURATION="$SECONDS"

  if [ $RESPONSE_CODE -eq 0 ]; then
    echo -e "${GREEN} Test \"$TEST_ARG\" successful ($DURATION sec) $NC"
  else
    if [[ -n "$RES" ]]; then
      echo -e "\nLog:\n"
      echo "$RES"
    fi
    echo -e "${RED} Test \"$TEST_ARG\" failed $NC ($DURATION sec) $NC"
    exit $RESPONSE_CODE
  fi
}

get_test_runner() {
  local test_env="$1"
  if [[ "${test_env}" != "ci" && "${test_env}" != "local" ]]; then
    echo -e "${RED}test_env must be either 'local' or 'ci'"
    exit 1
  fi
  echo "run_test_${test_env}"
}
