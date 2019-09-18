# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scala_import_fetch_sources_with_env_bazel_jvm_fetch_sources_set_to() {
  # the existence of the env var should cause the import repository rule to re-fetch the dependency
  # and therefore the order of tests is not expected to matter
  export BAZEL_JVM_FETCH_SOURCES=$1
  local expect_failure=$2

  if [[ ${expect_failure} ]]; then
    action_should_fail test_scala_import_fetch_sources
  else
    test_scala_import_fetch_sources
  fi

  unset BAZEL_JVM_FETCH_SOURCES
}

test_scala_import_fetch_sources() {
  local srcjar_name="guava-21.0-src.jar"
  local bazel_out_external_guava_21=$(bazel info output_base)/external/com_google_guava_guava_21_0

  set -e
  bazel build //test/src/main/scala/scalarules/test/fetch_sources/...
  set +e

  assert_file_exists $bazel_out_external_guava_21/$srcjar_name
}

assert_file_exists() {
  if [[ -f $1 ]]; then
    echo "File $1 exists."
    exit 0
  else
    echo "File $1 does not exist."
    exit 1
  fi
}

test_scala_import_source_jar_should_be_fetched_when_fetch_sources_is_set_to_true() {
  test_scala_import_fetch_sources
}

test_scala_import_source_jar_should_be_fetched_when_env_bazel_jvm_fetch_sources_is_set_to_true() {
  test_scala_import_fetch_sources_with_env_bazel_jvm_fetch_sources_set_to "TruE" # as implied, the value is case insensitive
}

test_scala_import_source_jar_should_not_be_fetched_when_env_bazel_jvm_fetch_sources_is_set_to_non_true() {
  test_scala_import_fetch_sources_with_env_bazel_jvm_fetch_sources_set_to "false" "and expect no source jars"
}

$runner test_scala_import_source_jar_should_be_fetched_when_fetch_sources_is_set_to_true
$runner test_scala_import_source_jar_should_be_fetched_when_env_bazel_jvm_fetch_sources_is_set_to_true
$runner test_scala_import_source_jar_should_not_be_fetched_when_env_bazel_jvm_fetch_sources_is_set_to_non_true
