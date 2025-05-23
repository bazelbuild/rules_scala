#!/usr/bin/env bash

# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

test_scala_classpath_resources_expect_warning_on_namespace_conflict() {
  local package_path='test/src/main/scala/scalarules/test/classpath_resources'
  local target="classpath_resource_duplicates"
  local output=''
  local expected=(
    "Classpath resource file classpath-resource has a namespace conflict"
    "with another file: classpath-resource"
  )

  rm -rf "bazel-bin/${package_path}/${target}"*
  output="$(bazel build --verbose_failures "//${package_path}:${target}" 2>&1)"
  expected="${expected[*]}"

  if ! grep "$expected" <<<"$output"; then
    echo "output:"
    echo "$output"
    echo  " ${RED}Expected \"$expected\" in output, but was not found.${NC}"
    exit 1
  fi
}

$runner test_scala_classpath_resources_expect_warning_on_namespace_conflict
