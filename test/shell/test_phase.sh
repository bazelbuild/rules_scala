# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

output_file_should_contain_message() {
  set +e
  MSG=$1
  TEST_ARG=${@:2}
  OUTPUT_FILE=$(echo ${@:3} | sed 's#//#/#g;s#:#/#g')
  OUTPUT_PATH=$(bazel info bazel-bin)/$OUTPUT_FILE
  bazel $TEST_ARG
  RESPONSE_CODE=$?
  cat $OUTPUT_PATH | grep -- "$MSG"
  GREP_RES=$?
  if [ $RESPONSE_CODE -ne 0 ]; then
    echo -e "${RED} \"bazel $TEST_ARG\" should pass but failed. $NC"
    exit 1
  elif [ $GREP_RES -ne 0 ]; then
    echo -e "${RED} \"bazel $TEST_ARG\" should pass with \"$MSG\" in file \"$OUTPUT_FILE\" but did not. $NC"
    exit 1
  else
    exit 0
  fi
}

test_scala_binary_with_extra_phase() {
  output_file_should_contain_message \
    "This is custom content" \
    build //test/phase/add_phase_to_all_rules:HelloBinary.custom-output
}

test_scala_library_with_extra_phase_and_custom_content() {
  output_file_should_contain_message \
    "This is custom content in library" \
    build //test/phase/add_phase_to_all_rules:HelloLibrary.custom-output
}

test_scala_library_for_plugin_bootstrapping_with_extra_phase_and_custom_content() {
  output_file_should_contain_message \
    "This is custom content in library_for_plugin_bootstrapping" \
    build //test/phase/add_phase_to_all_rules:HelloLibraryForPluginBootstrapping.custom-output
}

test_scala_macro_library_with_extra_phase_and_custom_content() {
  output_file_should_contain_message \
    "This is custom content in macro_library" \
    build //test/phase/add_phase_to_all_rules:HelloMacroLibrary.custom-output
}

test_scala_test_with_extra_phase_and_custom_content() {
  output_file_should_contain_message \
    "This is custom content in test" \
    build //test/phase/add_phase_to_all_rules:HelloTest.custom-output
}

test_scala_junit_test_with_extra_phase_and_custom_content() {
  output_file_should_contain_message \
    "This is custom content in junit_test" \
    build //test/phase/add_phase_to_all_rules:HelloJunitTest.custom-output
}

test_scala_repl_with_extra_phase_and_custom_content() {
  output_file_should_contain_message \
    "This is custom content in repl" \
    build //test/phase/add_phase_to_all_rules:HelloRepl.custom-output
}

$runner test_scala_binary_with_extra_phase
$runner test_scala_library_with_extra_phase_and_custom_content
$runner test_scala_library_for_plugin_bootstrapping_with_extra_phase_and_custom_content
$runner test_scala_macro_library_with_extra_phase_and_custom_content
$runner test_scala_test_with_extra_phase_and_custom_content
$runner test_scala_junit_test_with_extra_phase_and_custom_content
$runner test_scala_repl_with_extra_phase_and_custom_content
