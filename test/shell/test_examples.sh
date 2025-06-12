#!/usr/bin/env bash
#
# Tests for `examples/` repositories

set -e

dir="$( cd "${BASH_SOURCE[0]%/*}" && echo "${PWD%/test/shell}" )"
test_source="${dir}/test/shell/${BASH_SOURCE[0]#*test/shell/}"
# shellcheck source=./test_runner.sh
. "${dir}"/test/shell/test_runner.sh
export USE_BAZEL_VERSION=${USE_BAZEL_VERSION:-$(cat $dir/.bazelversion)}

run_in_example_dir(){
  local test_dir="$1";
  shift

  set -e
  cd "examples/${test_dir}"
  "$@"
  bazel shutdown
  cd "$dir"
}

test_scalatest_repositories_example() {
  run_in_example_dir testing/scalatest_repositories bazel test //...
}

test_specs2_junit_repositories_example() {
  run_in_example_dir testing/specs2_junit_repositories bazel test //...
}

test_multi_framework_toolchain_example() {
  run_in_example_dir testing/multi_frameworks_toolchain bazel test //...
}

test_scala3_1_example() {
  run_in_example_dir scala3 bazel build --repo_env=SCALA_VERSION=3.1.3 //...
}

test_scala3_2_example() {
  run_in_example_dir scala3 bazel build --repo_env=SCALA_VERSION=3.2.2 //...
}

test_scala3_3_example() {
  run_in_example_dir scala3 bazel build --repo_env=SCALA_VERSION=3.3.6 //...
}

test_scala3_4_example() {
   run_in_example_dir scala3 bazel build --repo_env=SCALA_VERSION=3.4.3 //...
}

test_scala3_5_example() {
   run_in_example_dir scala3 bazel build --repo_env=SCALA_VERSION=3.5.2 //...
}

test_scala3_6_example() {
   run_in_example_dir scala3 bazel build --repo_env=SCALA_VERSION=3.6.4 //...
}

test_scala3_7_example() {
   run_in_example_dir scala3 bazel build --repo_env=SCALA_VERSION=3.7.1 //...
}

test_semanticdb_example() {
  build_semanticdb_example(){
    bazel build //... --aspects aspect.bzl%semanticdb_info_aspect \
      --output_groups=json_output_file
    echo
    bazel build //...
  }

  run_in_example_dir semanticdb build_semanticdb_example
}

test_cross_build_example() {
  run_in_example_dir crossbuild bazel build //...
}

test_overridden_artifacts_example() {
  run_in_example_dir overridden_artifacts bazel test --test_output=errors //...
}

test_twitter_scrooge_example() {
  # Tests for twitter_scrooge toolchain setup problems under Bzlmod from #1744.
  # Neither of the errors occurred under `WORKSPACE`
  build_twitter_scrooge_example() {
    # `ERROR: no such package '@@[unknown repo...`
    bazel build //...
    echo

    # `expected value of type 'string' for dict value element, but got Label`
    bazel build //:justscrooge
  }

  run_in_example_dir twitter_scrooge build_twitter_scrooge_example
}

run_tests "$test_source" "$(get_test_runner "${1:-local}")"
