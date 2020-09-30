# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# '.' means include in bach ;)
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

assert_file_exists() {
  file_name=$1
  if [[ -f ${file_name} ]]; then
    echo "File ${file_name} does exist!"
    exit 0
  else
    echo "File ${file_name} does not exist."
    exit 1
  fi
}

test_custom_reporter_class_has_been_set() {
  local custom_reporter_check_file="custom_reporter_check"
  # set -e means "exit immediately on non-zero exit status"
  set -e
  bazel test test/scala_test:custom_reporter
  set +e
  reporter_output_dir="$(bazel info bazel-testlogs)/test/scala_test/custom_reporter/test.outputs"
  reporter_output_filepath="${reporter_output_dir}/${custom_reporter_check_file}"
  unzip -oq "${reporter_output_dir}/outputs.zip" -d "${reporter_output_dir}"
  assert_file_exists "${reporter_output_filepath}"
}

$runner test_custom_reporter_class_has_been_set