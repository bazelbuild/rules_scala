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

function multi_framework_toolchain_example() {
  (cd examples/testing/multi_frameworks_toolchain; bazel test //...)
}

function scala3_1_example() {
  (cd examples/scala3; bazel build --repo_env=SCALA_VERSION=3.1.0 //...)
}

function scala3_2_example() {
  (cd examples/scala3; bazel build --repo_env=SCALA_VERSION=3.2.1 //...)
}

function test_produces_semanticdb_scala3() {
  # NB: In subshell, so "cd" doesn't change local CWD 
  (
    cd examples/testing/semanticdb_scala3
    bazel run --extra_toolchains=//:semanticdb_toolchain //:run

    local JAR="$(bazel info bazel-bin)/all.jar" 

    if ! jar_contains_files $JAR "Foo.scala.semanticdb" "Main.scala.semanticdb"; then
      echo "SemanticDB output not included in jar $JAR"
      exit 1
    fi
  )
}

$runner scalatest_repositories_example
$runner specs2_junit_repositories_example
$runner multi_framework_toolchain_example
$runner scala3_1_example
$runner scala3_2_example
$runner test_produces_semanticdb_scala3