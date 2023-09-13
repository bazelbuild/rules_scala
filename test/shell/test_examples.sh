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

function scala3_3_example() {
  (cd examples/scala3; bazel build --repo_env=SCALA_VERSION=3.3.0 //...)
}

function semanticdb_example() {
  set -e
  ( cd examples/semanticdb; 
    bazel build //... --aspects aspect.bzl%semanticdb_info_aspect --output_groups=json_output_file;
    bazel build //...
  )
}

$runner scalatest_repositories_example
$runner specs2_junit_repositories_example
$runner multi_framework_toolchain_example
$runner semanticdb_example
$runner scala3_1_example
$runner scala3_2_example
$runner scala3_3_example