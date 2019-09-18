# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

test_scala_classpath_resources_expect_warning_on_namespace_conflict() {
  local output=$(bazel build \
    --verbose_failures \
    //test/src/main/scala/scalarules/test/classpath_resources:classpath_resource_duplicates
  )

  local expected="Classpath resource file classpath-resourcehas a namespace conflict with another file: classpath-resource"

  if ! grep "$method" <<<$output; then
    echo "output:"
    echo "$output"
    echo "Expected $method in output, but was not found."
    exit 1
  fi
}

$runner test_scala_classpath_resources_expect_warning_on_namespace_conflict
