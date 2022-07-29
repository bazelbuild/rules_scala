# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scala_test_testfilter_class_selection() {
  bazel test --test_output=errors --test_filter=A //test_expect_failure/scala_test_testfilter:tests
}

test_scala_test_testfilter_method_selection() {
  bazel test --test_output=errors --test_filter=A --test_arg=-t --test_arg="test 1" //test_expect_failure/scala_test_testfilter:tests
}

$runner test_scala_test_testfilter_class_selection
$runner test_scala_test_testfilter_method_selection