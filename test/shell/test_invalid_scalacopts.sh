# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_logs_contains() {
  scalaVersion=$1
  expected=$2
  
  bazel build \
   --repo_env=SCALA_VERSION=${scalaVersion} \
   //test_expect_failure/scalacopts_invalid:empty \
   2>&1 | grep "$expected"
}

test_logs_not_contains() {
  scalaVersion=$1
  expected=$2

  bazel build \
   --repo_env=SCALA_VERSION=${scalaVersion} \
   //test_expect_failure/scalacopts_invalid:empty \
   2>&1 | grep -v "$expected"
}

for scalaVersion in 2.12.19 2.13.14 3.3.3; do
  if [[ "$scalaVersion" == 3.* ]]; then
    $runner test_logs_contains $scalaVersion "not-existing is not a valid choice for -source"
  else
    $runner test_logs_contains $scalaVersion "bad option: '-source:not-existing'"
  fi
  $runner test_logs_contains $scalaVersion 'Failed to invoke Scala compiler, ensure passed options are valid'
  $runner test_logs_not_contains $scalaVersion 'at io.bazel.rulesscala.scalac.ScalacWorker.main'
done
