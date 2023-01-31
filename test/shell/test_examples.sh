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

function scala3_example() {
  (cd examples/scala3; bazel build //...)
}

function test_produces_semanticdb_scala3() {
  # NB: In subshell, so CD doesn't change local CWD 
  (
    cd examples/testing/semanticdb_scala3
    bazel run --extra_toolchains=//:semanticdb_toolchain //:run

    local OUT_DIR="$(bazel info bazel-bin)/all.semanticdb" 
    if [ ! -d "$OUT_DIR" ]; then
      echo "No SemanticDB out directory"
      exit 1
    fi

    local SIZE=$(du -s $OUT_DIR | cut -f1)
    if (( SIZE < 8 )); then
      echo "No SemanticDb files produced"
      exit 1
    fi
  )
}

$runner scalatest_repositories_example
$runner specs2_junit_repositories_example
$runner multi_framework_toolchain_example
$runner scala3_example
$runner test_produces_semanticdb_scala3
