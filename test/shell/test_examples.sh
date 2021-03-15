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

function build_java_with_javabase_11_and_host_javabase_11() {
  (cd examples/jdk; bazel clean && bazel run --javabase=:jdk11 --host_javabase=:jdk11 :MainJava)
}

function build_java_with_javabase_8_and_host_javabase_8() {
  (cd examples/jdk; bazel clean && bazel run --javabase=:jdk8 --java_toolchain=:toolchain_java8 --host_javabase=:jdk8 --host_java_toolchain=:toolchain_java8 :MainJava)
}

function build_java_with_javabase_8_and_host_javabase_11() {
  (cd examples/jdk; bazel clean && bazel run --javabase=:jdk8 --host_javabase=:jdk11 :MainJava)
}

function build_scala_with_javabase_11_and_host_javabase_11() {
  (cd examples/jdk; bazel clean && bazel run --javabase=:jdk11 --host_javabase=:jdk11 :MainScala)
}

function build_scala_with_javabase_8_and_host_javabase_8() {
  (cd examples/jdk; bazel clean && bazel run --javabase=:jdk8 --java_toolchain=:toolchain_java8 --host_javabase=:jdk8 --host_java_toolchain=:toolchain_java8 :MainScala)
}

function build_scala_with_javabase_8_and_host_javabase_11() {
  (cd examples/jdk; bazel clean && bazel run --javabase=:jdk8 --host_javabase=:jdk11 :MainScala)
}

$runner scalatest_repositories_example
$runner specs2_junit_repositories_example

$runner build_java_with_javabase_11_and_host_javabase_11
$runner build_java_with_javabase_8_and_host_javabase_8
$runner build_java_with_javabase_8_and_host_javabase_11

for scala_version in "2.11.12" "2.12.11" "2.13.3"
do
  echo "Running java cross compile tests for scala $scala_version"
  sed "s/scala_config()/scala_config(scala_version = \"$scala_version\")/g" examples/jdk/WORKSPACE > examples/jdk/WORKSPACE.bazel
  $runner build_scala_with_javabase_11_and_host_javabase_11
  $runner build_scala_with_javabase_8_and_host_javabase_8
  $runner build_scala_with_javabase_8_and_host_javabase_11
done
