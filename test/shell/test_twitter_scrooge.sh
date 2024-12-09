# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

scrooge_compile_with_jdk_11() {
    bazel build \
        --java_language_version=11 \
        --tool_java_language_version=11 \
        --java_runtime_version=remotejdk_11 \
        --tool_java_runtime_version=remotejdk_11 \
        test/src/main/scala/scalarules/test/twitter_scrooge/...
}

$runner scrooge_compile_with_jdk_11
