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

  PACKAGE_DIR=$1
  RULE_TYPE=$2
  FILENAME=$3

  #on windows scalafmt targets need to be run using bash. 
  #TODO: improve the scalafmt funcitonality so we don't need to use the run_under mechanism
  local run_under=""
  if is_windows; then
    run_under="--run_under=bash"
  fi

  bazel run //$PACKAGE_DIR:formatted-$RULE_TYPE.format-test $run_under
  if [ $? -ne 0 ]; then
    echo -e "${RED} formatted-$RULE_TYPE.format-test should be a formatted target. $NC"
    exit 1
  fi

  bazel run //$PACKAGE_DIR:unformatted-$RULE_TYPE.format-test $run_under
  if [ $? -eq 0 ]; then
    echo -e "${RED} unformatted-$RULE_TYPE.format-test should be an unformatted target. $NC"
    exit 1
  fi

  backup_unformatted $PACKAGE_DIR $FILENAME
  # format unformatted*.scala

  bazel run //$PACKAGE_DIR:unformatted-$RULE_TYPE.format $run_under
  if [ $? -ne 0 ]; then
    echo -e "${RED} unformatted-$RULE_TYPE.format should run formatting. $NC"
    restore_unformatted_before_exit $PACKAGE_DIR $FILENAME
    exit 1
  fi

  diff $FILE_PATH/unformatted/unformatted-$FILENAME.scala $FILE_PATH/formatted/formatted-$FILENAME.scala
  if [ $? -ne 0 ]; then
    echo -e "${RED} unformatted-$FILENAME.scala should be the same as formatted-$FILENAME.scala after formatting. $NC"
    restore_unformatted_before_exit $PACKAGE_DIR $FILENAME
    exit 1
  fi
  restore_unformatted_before_exit $FILE_PATH $FILENAME
}
