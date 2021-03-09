# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

function scalatest_repositories_example() {
  (cd examples/testing/scalatest_repositories; bazel test //...)
}

function specs2_junit_repositories_example() {
  (cd examples/testing/specs2_junit_repositories; bazel test //...)
}

function build_java_with_javabase_8_and_host_javabase_11() {
  (cd examples/jdk; bazel clean && bazel run --javabase=:jdk8 --host_javabase=:jdk11 :MainJava)
}

function build_scala_with_javabase_8_and_host_javabase_11() {
  (cd examples/jdk; bazel clean && bazel run --javabase=:jdk8 --host_javabase=:jdk11 :MainScala)
}

$runner scalatest_repositories_example
$runner specs2_junit_repositories_example
$runner build_java_with_javabase_8_and_host_javabase_11
$runner build_scala_with_javabase_8_and_host_javabase_11
