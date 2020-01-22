# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

backup_unformatted_file() {
  FILE_PATH=$1
  FILENAME=$2
  cp $FILE_PATH/unformatted/un${FILENAME}.scala $FILE_PATH/unformatted/un${FILENAME}.backup.scala
}

restore_unformatted_file_before_exit() {
  FILE_PATH=$1
  FILENAME=$2
  cp $FILE_PATH/unformatted/un${FILENAME}.backup.scala $FILE_PATH/unformatted/un${FILENAME}.scala
  rm -f $FILE_PATH/unformatted/un${FILENAME}.backup.scala
}

run_formatting() {
  set +e

  FILE_PATH="$( dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) )"/scalafmt
  RULE_TYPE=$1
  FILENAME="formatted"
  if [[ $RULE_TYPE = test ]]; then
    FILENAME="formatted-test"
  elif [[ $RULE_TYPE = custom-conf ]]; then
    FILENAME="formatted-custom-conf"
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

  backup_unformatted_file $FILE_PATH $FILENAME
  # format unformatted*.scala
  bazel run //test/scalafmt:unformatted-$RULE_TYPE.format
  if [ $? -ne 0 ]; then
    echo -e "${RED} unformatted-$RULE_TYPE.format should run formatting. $NC"
    restore_unformatted_file_before_exit $FILE_PATH $FILENAME
    exit 1
  fi

  diff $FILE_PATH/unformatted/un${FILENAME}.scala $FILE_PATH/formatted/${FILENAME}.scala
  if [ $? -ne 0 ]; then
    echo -e "${RED} un${FILENAME}.scala should be the same as ${FILENAME}.scala after formatting. $NC"
    restore_unformatted_file_before_exit $FILE_PATH $FILENAME
    exit 1
  fi
  restore_unformatted_file_before_exit $FILE_PATH $FILENAME
}

test_scalafmt_binary() {
  run_formatting binary
}

test_scalafmt_library() {
  run_formatting library
}

test_scalafmt_test() {
  run_formatting test
}
test_custom_conf() {
  run_formatting custom-conf
}

$runner test_scalafmt_binary
$runner test_scalafmt_library
$runner test_scalafmt_test
$runner test_custom_conf