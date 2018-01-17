#!/bin/bash
#
# Test runner functions for rules_scala integration tests.

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
TIMOUT=60

run_test_ci() {
  # spawns the test to new process
  local TEST_ARG=$@
  local log_file=output_$$.log
  echo "running test $TEST_ARG"
  $TEST_ARG &>$log_file &
  local test_pid=$!
  SECONDS=0
  test_pulse_printer $! $TIMOUT $TEST_ARG &
  local pulse_printer_pid=$!
  local result

  {
    wait $test_pid 2>/dev/null
    result=$?
    kill $pulse_printer_pid && wait $pulse_printer_pid 2>/dev/null || true
  } || return 1

  DURATION=$SECONDS
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
  local test_pid=$1
  shift
  local timeout=$1 # in minutes
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
  SECONDS=0
  TEST_ARG=$@
  echo "running test $TEST_ARG"
  RES=$($TEST_ARG 2>&1)
  RESPONSE_CODE=$?
  DURATION=$SECONDS
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo -e "${GREEN} Test \"$TEST_ARG\" successful ($DURATION sec) $NC"
  else
    echo -e "\nLog:\n"
    echo "$RES"
    echo -e "${RED} Test \"$TEST_ARG\" failed $NC ($DURATION sec) $NC"
    exit $RESPONSE_CODE
  fi
}

get_test_runner() {
  test_env=$1
  if [[ "${test_env}" != "ci" && "${test_env}" != "local" ]]; then
    echo -e "${RED}test_env must be either 'local' or 'ci'"
    exit 1
  fi
  echo "run_test_${test_env}"
}