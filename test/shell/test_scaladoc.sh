# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

_check_file_existence() {
  local filepath=$1
  local expect=$2 #1 for yes, 0 for no
  
  if [[ -f "$filepath" ]] ; then 
    if [[ $expect == 0 ]]; then 
      echo "Error: Unexpected scaladoc file found: ${filepath} "
      exit 1;
    fi    
  else
    if [[ $expect == 1 ]]; then
      echo "Error: Expected scaladoc file not found: ${filepath} "
      exit 1;
    fi
  fi    
}

test_scaladoc_transitive() {
  #Verify that docs are generated for B AND A. (B depends on A).
  set -e

  bazel build //test_expect_failure/scaladoc:scaladoc_transitive --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn

  local scaladoc_outpath="$(bazel cquery //test_expect_failure/scaladoc:scaladoc_transitive --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn --output=files)"  

  _check_file_existence ${scaladoc_outpath}/"B$.html" 1
  _check_file_existence ${scaladoc_outpath}/"A$.html" 1  
}

test_scaladoc_intransitive() {
  #Verify that docs only generated for B. (B depends on A)

  set -e

  bazel build //test_expect_failure/scaladoc:scaladoc_intransitive  --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn
  
  local scaladoc_outpath="$(bazel cquery //test_expect_failure/scaladoc:scaladoc_intransitive --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn --output=files)"  

  _check_file_existence ${scaladoc_outpath}/"B$.html" 1
  _check_file_existence ${scaladoc_outpath}/"A$.html" 0  
}

test_scaladoc_works_with_transitive_external_deps() {
  #Tests absense of a bug where scaladoc rule wasn't handling transitive dependencies that aren't scala_xxxx (i.e. don't hav a srcs attribute)
  #Note: need to use a plus-one toolchain to enable transitive deps.

  set -e
  
  #Just make sure it builds correctly
  bazel build //test_expect_failure/scaladoc:scaladoc_C --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn
   
}

$runner test_scaladoc_intransitive
$runner test_scaladoc_transitive
$runner test_scaladoc_works_with_transitive_external_deps
