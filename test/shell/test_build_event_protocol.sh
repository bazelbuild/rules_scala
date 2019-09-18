# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

scala_binary_common_jar_is_exposed_in_build_event_protocol() {
  local target=$1
  set +e
  bazel build test:$target --build_event_text_file=$target_bes.txt
  cat $target_bes.txt | grep "test/$target.jar"
  if [ $? -ne 0 ]; then
    echo "test/$target.jar was not found in build event protocol:"
    cat $target_bes.txt
    rm $target_bes.txt
    exit 1
  fi

  rm $target_bes.txt
  set -e
}

scala_binary_jar_is_exposed_in_build_event_protocol() {
  scala_binary_common_jar_is_exposed_in_build_event_protocol ScalaLibBinary
}

scala_test_jar_is_exposed_in_build_event_protocol() {
  scala_binary_common_jar_is_exposed_in_build_event_protocol HelloLibTest
}

scala_junit_test_jar_is_exposed_in_build_event_protocol() {
  scala_binary_common_jar_is_exposed_in_build_event_protocol JunitTestWithDeps
}

$runner scala_binary_jar_is_exposed_in_build_event_protocol
$runner scala_test_jar_is_exposed_in_build_event_protocol
$runner scala_junit_test_jar_is_exposed_in_build_event_protocol
