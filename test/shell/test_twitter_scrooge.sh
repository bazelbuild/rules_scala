# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

scrooge_compile_with_jdk_11() {
    # javabase and java_toolchain parameters are deprecated and may be
    # removed in Bazel >= 5.0.0
    bazel build --javabase=@bazel_tools//tools/jdk:remote_jdk11 \
        --host_javabase=@bazel_tools//tools/jdk:remote_jdk11 \
        --host_java_toolchain=@bazel_tools//tools/jdk:toolchain_java11 \
        --java_toolchain=@bazel_tools//tools/jdk:toolchain_java11 \
        --javacopt='--release 11' \
        --java_language_version=11 \
        --tool_java_language_version=11 \
        --java_runtime_version=remotejdk_11 \
        --tool_java_runtime_version=remotejdk_11 \
        test/src/main/scala/scalarules/test/twitter_scrooge/...
}

$runner scrooge_compile_with_jdk_11
