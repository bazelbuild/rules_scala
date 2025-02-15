# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_classpath_contains_2_12() {
  bazel aquery 'mnemonic("Javac", //src/java/io/bazel/rulesscala/scalac:scalac)' \
   --repo_env=SCALA_VERSION=2.12.20 \
   | grep scala-library-2.12
}

test_classpath_contains_2_13() {
  bazel aquery 'mnemonic("Javac", //src/java/io/bazel/rulesscala/scalac:scalac)' \
   --repo_env=SCALA_VERSION=2.13.16 \
   | grep scala-library-2.13
}

test_scala_config_content() {
  bazel build --repo_env=SCALA_VERSION=0.0.0 @io_bazel_rules_scala_config//:all 2> /dev/null
  grep "SCALA_MAJOR_VERSION='0.0'" \
    "$(bazel info output_base)"/external/*io_bazel_rules_scala_config/config.bzl
}

$runner test_classpath_contains_2_12
$runner test_classpath_contains_2_13
$runner test_scala_config_content
