backup_unformatted() {
  local FILE_PATH="$1"
  local FILENAME="$2"
  cp "$FILE_PATH/unformatted/unformatted-$FILENAME.scala" \
    "$FILE_PATH/unformatted/unformatted-$FILENAME.backup.scala"
}

restore_unformatted_before_exit() {
  local FILE_PATH="$1"
  local FILENAME="$2"
  cp "$FILE_PATH/unformatted/unformatted-$FILENAME.backup.scala" \
    "$FILE_PATH/unformatted/unformatted-$FILENAME.scala"
  rm -f "$FILE_PATH/unformatted/unformatted-$FILENAME.backup.scala"
}

run_formatting() {
  set +e

  local PACKAGE_DIR="$1"
  local RULE_TYPE="$2"
  local FILENAME="$3"

  #on windows scalafmt targets need to be run using bash. 
  #TODO: improve the scalafmt funcitonality so we don't need to use the run_under mechanism
  local bazel_run=('bazel' 'run')
  if is_windows; then
    bazel_run+=('--run_under=bash')
  fi

  "${bazel_run[@]}" "//$PACKAGE_DIR:formatted-$RULE_TYPE.format-test"
  if [ $? -ne 0 ]; then
    echo -e "${RED} formatted-$RULE_TYPE.format-test should be a formatted target. $NC"
    exit 1
  fi

  "${bazel_run[@]}" "//$PACKAGE_DIR:unformatted-$RULE_TYPE.format-test"
  if [ $? -eq 0 ]; then
    echo -e "${RED} unformatted-$RULE_TYPE.format-test should be an unformatted target. $NC"
    exit 1
  fi

  backup_unformatted "$PACKAGE_DIR" "$FILENAME"
  # format unformatted*.scala

  "${bazel_run[@]}" "//$PACKAGE_DIR:unformatted-$RULE_TYPE.format"
  if [ $? -ne 0 ]; then
    echo -e "${RED} unformatted-$RULE_TYPE.format should run formatting. $NC"
    restore_unformatted_before_exit "$PACKAGE_DIR" "$FILENAME"
    exit 1
  fi

  diff "$PACKAGE_DIR/unformatted/unformatted-$FILENAME.scala" \
    "$PACKAGE_DIR/formatted/formatted-$FILENAME.scala"
  if [ $? -ne 0 ]; then
    echo -e "${RED} unformatted-$FILENAME.scala should be the same as formatted-$FILENAME.scala after formatting. $NC"
    restore_unformatted_before_exit "$PACKAGE_DIR" "$FILENAME"
    exit 1
  fi
  restore_unformatted_before_exit "$PACKAGE_DIR" "$FILENAME"
}
