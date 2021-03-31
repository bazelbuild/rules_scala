# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_default_scala_library_version_on_classpath() {
  bazel aquery 'mnemonic("Javac", //src/java/io/bazel/rulesscala/scalac:scalac)' \
   | grep scala-library-2.12.11
}

test_overwritten_scala_library_version_on_classpath() {
  bazel aquery 'mnemonic("Javac", //src/java/io/bazel/rulesscala/scalac:scalac)' \
   --repo_env=SCALA_VERSION_OVERRIDE=2.13.x \
   | grep scala-library-2.13.3
}

$runner test_default_scala_library_version_on_classpath
$runner test_overwritten_scala_library_version_on_classpath
