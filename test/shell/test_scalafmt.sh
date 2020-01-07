# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

run_non_default_formatting() {
  set +e

  FILE_PATH="$( dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) )"/scalafmt
  RULE_TYPE=$1
  FILENAME="formatted"
  if [[ $RULE_TYPE = test ]]; then
    FILENAME="formatted-test"
  fi
    
  bazel run //test/scalafmt:formatted-$RULE_TYPE.format-test
  if [ $? -ne 0 ]; then
    echo -e "${RED} formatted-$RULE_TYPE.format-test should be a formatted target. $NC"
    exit 1
  fi

  bazel run //test/scalafmt:unformatted-$RULE_TYPE.format-test
  if [ $? -eq 0 ]; then
    echo -e "${RED} unformatted-$RULE_TYPE.format-test should be an unformatted target. $NC"
    exit 1
  fi

  bazel run //test/scalafmt:unformatted-$RULE_TYPE.format
  if [ $? -ne 0 ]; then
    echo -e "${RED} unformatted-$RULE_TYPE.format should run formatting. $NC"
    exit 1
  fi

  diff $FILE_PATH/un${FILENAME}.scala $FILE_PATH/${FILENAME}.scala
  if [ $? -ne 0 ]; then
    echo -e "${RED} un${FILENAME}.scala should be the same as ${FILENAME}.scala after formatting. $NC"
    exit 1
  fi

  cp $FILE_PATH/un${FILENAME}.template.scala $FILE_PATH/un${FILENAME}.scala
}

test_scalafmt_binary() {
  run_non_default_formatting binary
}

test_scalafmt_library() {
  run_non_default_formatting library
}

test_scalafmt_test() {
  run_non_default_formatting test
}

$runner test_scalafmt_binary
$runner test_scalafmt_library
$runner test_scalafmt_test
