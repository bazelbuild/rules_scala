# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

FILES=("A.scala.semanticdb" "B.scala.semanticdb")

jar_contains_files() {
  for arg in "${@:2}"
  do
    if ! jar tf $1 | grep $arg; then
      return 1
    fi
  done
}

test_produces_semanticdb(){
  set -e

  local scala_majver=$1
  local is_bundle=$2


  if [ $is_bundle -eq 1 ]; then
    local toolchain="--extra_toolchains=//test/semanticdb:semanticdb_bundle_toolchain"  
  else
    local toolchain="--extra_toolchains=//test/semanticdb:semanticdb_nobundle_toolchain"
  fi

  if [ $scala_majver -eq 3 ]; then
    local version_opt="--repo_env=SCALA_VERSION=3.3.1"
  fi


  bazel build //test/semanticdb:semantic_provider_vars_all  ${toolchain}  ${version_opt}

  #semantic_provider_vars.sh contains the SemanticdbInfo data  
  . $(bazel info bazel-bin)/test/semanticdb/semantic_provider_vars_all.sh

  #Check the Provider variables
  if [ $semanticdb_enabled -ne 1 ]; then
    echo "Error: SemanticdbInfo.semanticdb_enabled not equal to true"
    exit 1
  fi


  if [ $semanticdb_is_bundled -ne $is_bundle ]; then
    echo "Error: SemanticdbInfo.is_bundled_in_jar is incorrect."
    exit 1
  fi

  if [ $is_bundle -eq 0 ]; then
    if [[ $semanticdb_target_root == "" ]]; then
      echo "Error: SemanticdbInfo.target_root expected to have a value"
      exit 1
    fi
  else
    if [[ $semanticdb_target_root != "" ]]; then
      echo "Error: SemanticdbInfo.target_root expected to be empty string"
      exit 1
    fi
  fi 

  if [[ $scala_majver == 3 ]] && [[ $semanticdb_pluginjarpath != "" ]]; then
    echo "Error: SemanticdbInfo.pluginjarpath expected to be empty for scala 3"
    exit 1
  fi
  if [[ $scala_majver == 2 ]] && [[ $semanticdb_pluginjarpath == "" ]]; then
    echo "Error: SemanticdbInfo.pluginjarpath expected to be set for scala 2"
    exit 1
  fi

  if [ $is_bundle -eq 0 ]; then
    
    semanticdb_path="$(bazel info execution_root)/${semanticdb_target_root}/META-INF/semanticdb/test/semanticdb/"

    for arg in $FILES
      do
        if ! [ -f "${semanticdb_path}${arg}" ]; then
          echo "Error: Expected Semanticdb file not found: ${semanticdb_path}${arg}"
          exit 1;

        fi
      done
  fi
  
  local JAR="$(bazel info bazel-bin)/test/semanticdb/all_lib.jar" 

  if [ $is_bundle -eq 0 ]; then
    if jar_contains_files $JAR $FILES; then
      echo "Error: SemanticDB output erroneously included in jar: $JAR"
      exit 1
    fi
  else
    if ! jar_contains_files $JAR $FILES; then
      echo "Error: SemanticDB output not included in jar: $JAR"
      exit 1
    fi
  fi
}

test_empty_semanticdb(){
  #just make sure this special case of semanticdb with no source files builds fine

  set -e

  bazel build //test/semanticdb:semantic_provider_vars_empty --extra_toolchains=//test/semanticdb:semanticdb_nobundle_toolchain
}

test_no_semanticdb() {
  #verify no semanticdb files have been generated in the bin dir or bundled in the jar 

  set -e

  local jar="$(bazel info bazel-bin)/test/semanticdb/all_lib.jar" 
  local targetout_path="$(bazel info bazel-bin)/test/semanticdb"

  rm -rf $targetout_path #clean out the output dir for clean slate

  #bazel clean
  bazel build //test/semanticdb:all_lib

  #there should be no *.semanticdb files under the target's output dir
  if [ $( find $targetout_path -type f -name *.semanticdb | wc -l ) -gt 0 ] ; then
    echo "Error: Semanticdb files erroneously found in target output"
    exit 1
  fi

  if jar_contains_files $jar "${FILES[@]}"; then
    echo "Error: Semanticdb included in jar $JAR, but wasn't expected to be"
    exit 1
  fi
}

run_semanticdb_tests() {
  local bundle=1;   local nobundle=0
  local scala3=3;    local scala2=2

  $runner test_produces_semanticdb $scala2 $bundle 
  $runner test_produces_semanticdb $scala2 $nobundle 
  
  $runner test_empty_semanticdb

  $runner test_produces_semanticdb $scala3 $bundle 
  $runner test_produces_semanticdb $scala3 $nobundle 

  $runner test_no_semanticdb

}

run_semanticdb_tests
