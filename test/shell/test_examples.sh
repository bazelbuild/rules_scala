# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

function test_example(){ 
    local dir1=$1;
    local cmd1=$2;
  (
    set -e

    cd $dir1
    $cmd1
    bazel shutdown; #cleanup bazel process
  ) 
}

function scalatest_repositories_example() {
  test_example examples/testing/scalatest_repositories "bazel test //..."
}

function specs2_junit_repositories_example() {
  
  test_example examples/testing/specs2_junit_repositories "bazel test //..."
}

function multi_framework_toolchain_example() {
  test_example  examples/testing/multi_frameworks_toolchain "bazel test //..."
}

function scala3_1_example() {
  test_example examples/scala3 "bazel build --repo_env=SCALA_VERSION=3.1.3 //..."
}

function scala3_2_example() {
  test_example examples/scala3 "bazel build --repo_env=SCALA_VERSION=3.2.2 //..."
}

function scala3_3_example() {
  test_example examples/scala3 "bazel build --repo_env=SCALA_VERSION=3.3.4 //..."
}

function scala3_4_example() {
   test_example examples/scala3 "bazel build --repo_env=SCALA_VERSION=3.4.3 //..."
 }

function scala3_5_example() {
   test_example examples/scala3 "bazel build --repo_env=SCALA_VERSION=3.5.2 //..."
 }

function semanticdb_example() {

  function build_semanticdb_example(){
    bazel build //... --aspects aspect.bzl%semanticdb_info_aspect --output_groups=json_output_file
    bazel build //...
  }
  
  test_example examples/semanticdb build_semanticdb_example
}

function cross_build_example() {
  test_example examples/crossbuild "bazel build //..."
}

$runner scalatest_repositories_example
$runner specs2_junit_repositories_example
$runner multi_framework_toolchain_example
$runner semanticdb_example
$runner scala3_1_example
$runner scala3_2_example
$runner scala3_3_example
$runner scala3_4_example
$runner scala3_5_example
$runner cross_build_example