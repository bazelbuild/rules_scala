# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_classpath_contains_2_12() {
  bazel aquery 'mnemonic("Javac", //src/java/io/bazel/rulesscala/scalac:scalac)' \
   --repo_env=SCALA_VERSION=2.12.x \
   | grep scala-library-2.12
}

test_classpath_contains_2_13() {
  bazel aquery 'mnemonic("Javac", //src/java/io/bazel/rulesscala/scalac:scalac)' \
   --repo_env=SCALA_VERSION=2.13.x \
   | grep scala-library-2.13
}

$runner test_classpath_contains_2_12
$runner test_classpath_contains_2_13
