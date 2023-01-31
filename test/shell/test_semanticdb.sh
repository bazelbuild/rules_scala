# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_produces_semanticdb() {
  bazel build \
    --extra_toolchains=//test/semanticdb:semanticdb_toolchain \
    //test/semanticdb/...

  local OUT_DIR="$(bazel info bazel-bin)/test/semanticdb/all.semanticdb" 

  if [ ! -d "$OUT_DIR" ]; then
    echo "No SemanticDB out directory"
    exit 1
  fi

  local SIZE=$(du -s $OUT_DIR | cut -f1)
  if (( SIZE < 8 )); then
    echo "No SemanticDb files produced"
    exit 1
  fi
}

test_no_semanticdb() {
  bazel clean
  bazel build \
    //test/semanticdb/...

  local OUT_DIR="$(bazel info bazel-bin)/test/semanticdb/all.semanticdb" 

  if [ -d "$OUT_DIR" ]; then
    echo "Got SemanticDB out directory, but wasn't expecting it"
    exit 1
  fi
}

test_produces_semanticdb_scala3() {
  # NB: In subshell, so CD doesn't change local CWD 
  (
    cd test/semanticdb/scala3
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

$runner test_produces_semanticdb
$runner test_no_semanticdb