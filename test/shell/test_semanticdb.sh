# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

FILES=("A.scala.semanticdb" "B.scala.semanticdb")

test_produces_semanticdb() {
  bazel build \
    --extra_toolchains=//test/semanticdb:semanticdb_toolchain \
    //test/semanticdb/...

  local JAR="$(bazel info bazel-bin)/test/semanticdb/all.jar" 

  if ! jar_contains_files $JAR "${FILES[@]}"; then
    echo "SemanticDB output not included in jar $JAR"
    exit 1
  fi
}

test_no_semanticdb() {
  bazel clean
  bazel build \
    //test/semanticdb/...

  local JAR="$(bazel info bazel-bin)/test/semanticdb/all.jar" 

  if jar_contains_files $JAR "${FILES[@]}"; then
    echo "SemanticDB included in jar $JAR, but wasn't expected to be"
    exit 1
  fi
}

$runner test_produces_semanticdb
$runner test_no_semanticdb