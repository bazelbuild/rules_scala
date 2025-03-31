#!/usr/bin/env bash

set -e

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
rootdir="$(cd "${dir}/../.." && pwd)"
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")
test_tmpdir="${rootdir}/tmp/lint"
mkdir -p "$test_tmpdir"

check_module_bazel() {
  local repo_path="${1%MODULE.bazel}"
  local mod_orig="${test_tmpdir}/MODULE.lint"
  local mod_diff="${test_tmpdir}/MODULE.diff"

  echo -e "${GREEN}INFO:${NC} linting $1"
  repo_path="${repo_path:-.}"

  cd "${rootdir}/${repo_path}"
  cp MODULE.bazel "$mod_orig"

  trap "rm ${mod_orig} ${mod_diff}" EXIT
  bazel mod tidy
  bazel shutdown

  if ! diff -u "$mod_orig" MODULE.bazel >"$mod_diff"; then
    echo -e "${RED}ERROR:${NC}" \
      "\`bazel mod tidy\` produced changes in ${repo_path%.}MODULE.bazel:"
    echo "$(< "$mod_diff")"
    exit 1
  fi
}

while IFS= read -r module_file; do
  $runner check_module_bazel "$module_file"
done < <(git ls-files '**MODULE.bazel')

rm -rf "${test_tmpdir}"
