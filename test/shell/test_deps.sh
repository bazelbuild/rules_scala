# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

scala_pb_library_targets_do_not_have_host_deps() {
  set -e
  bazel build test/proto:test_binary_to_ensure_no_host_deps
  set +e
  find bazel-bin/test/proto/test_binary_to_ensure_no_host_deps.runfiles  -name '*.jar' -exec readlink {} \; | grep 'bazel-out/host'
  RET=$?
  set -e
  if [ "$RET" == "0" ]; then
    echo "Host deps exist in output of target:"
    echo "Possibly toolchains limitation?"
    find bazel-bin/test/proto/test_binary_to_ensure_no_host_deps.runfiles  -name '*.jar' -exec readlink {} \; | grep 'bazel-out/host'
    exit 1
  fi
}

scrooge_library_targets_do_not_have_host_deps() {
  set -e
  bazel build //test/src/main/scala/scalarules/test/twitter_scrooge:test_binary_to_ensure_no_host_deps
  set +e
  find bazel-bin/test/src/main/scala/scalarules/test/twitter_scrooge/test_binary_to_ensure_no_host_deps.runfiles  -name '*.jar' -exec readlink {} \; | grep 'bazel-out/host'
  RET=$?
  set -e
  if [ "$RET" == "0" ]; then
    echo "Host deps exist in output of target:"
    echo "Possibly toolchains limitation?"
    find bazel-bin/test/proto/test_binary_to_ensure_no_host_deps.runfiles  -name '*.jar' -exec readlink {} \; | grep 'bazel-out/host'
    exit 1
  fi
}

$runner scala_pb_library_targets_do_not_have_host_deps
$runner scrooge_library_targets_do_not_have_host_deps
