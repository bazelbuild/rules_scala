#!/bin/bash
#
# Test the IntelliJ aspect. Override intellij's rules_scala with this one for an
# integration test. See https://github.com/bazelbuild/rules_scala/issues/308.

set -euo pipefail

test_intellij_aspect() {
  local test_env=$1
  local intellij_git_tag=$2
  local -r rules_scala_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

  if [[ "${test_env}" == "ci" ]]; then
    # ci: intellij is checked out in `.travis.yaml`
    cd intellij || exit 1
  else
    # local: update or checkout a sibling dir.
    cd "${rules_scala_dir}/../" || exit 1
    test -d "intellij/.git" || git clone git@github.com:bazelbuild/intellij.git
    cd intellij && git fetch && git pull
  fi
  git checkout "${intellij_git_tag}"
  bazel test --test_output=errors --override_repository io_bazel_rules_scala="${rules_scala_dir}" //aspect/testing/tests/src/com/google/idea/blaze/aspect/scala/...
}

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
test_env="${1:-local}"

# shellcheck source=./test_runner.sh
. "${dir}"/test_runner.sh
runner=$(get_test_runner "$test_env")

$runner test_intellij_aspect "$test_env" master