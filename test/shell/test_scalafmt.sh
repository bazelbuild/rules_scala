# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

backup_unformatted() {
  FILE_PATH=$1
  FILENAME=$2
  cp $FILE_PATH/unformatted/unformatted-$FILENAME.scala $FILE_PATH/unformatted/unformatted-$FILENAME.backup.scala
}

restore_unformatted_before_exit() {
  FILE_PATH=$1
  FILENAME=$2
  cp $FILE_PATH/unformatted/unformatted-$FILENAME.backup.scala $FILE_PATH/unformatted/unformatted-$FILENAME.scala
  rm -f $FILE_PATH/unformatted/unformatted-$FILENAME.backup.scala
}

run_formatting() {
  set +e

  FILE_PATH="$( dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) )"/scalafmt
  RULE_TYPE=$1
  FILENAME=$2

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

  backup_unformatted $FILE_PATH $FILENAME
  # format unformatted*.scala
  bazel run //test/scalafmt:unformatted-$RULE_TYPE.format
  if [ $? -ne 0 ]; then
    echo -e "${RED} unformatted-$RULE_TYPE.format should run formatting. $NC"
    restore_unformatted_before_exit $FILE_PATH $FILENAME
    exit 1
  fi

  diff $FILE_PATH/unformatted/unformatted-$FILENAME.scala $FILE_PATH/formatted/formatted-$FILENAME.scala
  if [ $? -ne 0 ]; then
    echo -e "${RED} unformatted-$FILENAME.scala should be the same as formatted-$FILENAME.scala after formatting. $NC"
    restore_unformatted_before_exit $FILE_PATH $FILENAME
    exit 1
  fi
  restore_unformatted_before_exit $FILE_PATH $FILENAME
}

test_scalafmt_binary() {
  run_formatting binary encoding
}

test_scalafmt_library() {
  run_formatting library encoding
}

test_scalafmt_test() {
  run_formatting test test
}
test_custom_conf() {
  run_formatting custom-conf custom-conf
}

$runner test_scalafmt_binary
$runner test_scalafmt_library
$runner test_scalafmt_test
$runner test_custom_conf
