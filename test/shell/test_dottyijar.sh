# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

ijar_invariant() {
  cp "test/dottyijar/$3" "test/dottyijar/$2"
  trap "rm 'test/dottyijar/$2'" EXIT

  bazel build "//test/dottyijar:$1-dependent"

  ijar1_path="$(mktemp)"

  cp "bazel-bin/test/dottyijar/$1-ijar.jar" "$ijar1_path"

  cp "test/dottyijar/$4" "test/dottyijar/$2"
  bazel build "//test/dottyijar:$1-dependent"

  diff "$ijar1_path" "bazel-bin/test/dottyijar/$1-ijar.jar"
}

ijar_invariant_to_private_members() {
  ijar_invariant private-members PrivateMembers.scala PrivateMembers1.scala PrivateMembers2.scala
}

ijar_invariant_to_definition_values() {
  ijar_invariant definition-values DefinitionValues.scala DefinitionValues1.scala DefinitionValues2.scala
}

$runner ijar_invariant_to_private_members
$runner ijar_invariant_to_definition_values
