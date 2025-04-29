#!/usr/bin/env bash
#
# Verifies combinations of supported dependency versions.
#
# Starts by testing the oldest dependency versions, then increments some of them
# to more recent versions. These versions should match the guidance in these
# `README.md` sections:
#
# - Compatible Bazel versions
# - Using a precompiled protocol compiler > Minimum dependency versions
#
# Does not test the latest dependency versions, as all other tests in the suite
# already do this. Only builds with Bzlmod, as `WORKSPACE` builds are now
# considered legacy.

set -e

dir="$( cd "${BASH_SOURCE[0]%/*}" && echo "${PWD}" )"
test_source="${dir}/${BASH_SOURCE[0]##*/}"
# shellcheck source=./test_runner.sh
. "${dir}"/test/shell/test_runner.sh
. "${dir}"/test/shell/test_helper.sh

setup_suite() {
  original_dir="$PWD"
  setup_test_tmpdir_for_file "$dir" "$test_source"
  test_tmpdir="$PWD"

  if is_windows && [[ -z "$RULES_SCALA_TEST_REGEX" ]]; then
    # Windows now requires a precompiled protoc.
    windows_regex="test_precompiled_protoc"
  fi
}

teardown_suite() {
  teardown_test_tmpdir "$original_dir" "$test_tmpdir"
}

# Explicitly disable this, since this test sets the Bazel version.
export USE_BAZEL_VERSION=""

do_build_and_test() {
  # These are the minimum versions as described in `README.md` and as set in the
  # top level `MODULE.bazel` file. Update both if/when the first test test
  # fails. If another test fails, update the `README.md` informaton.
  local bazelversion="7.1.0"
  local skylib_version="1.6.0"
  local platforms_version="0.0.9"
  local protobuf_version="28.2"
  local rules_java_version="7.6.0"
  local rules_proto_version="6.0.0"
  local protoc_toolchain=""
  local legacy_api=""
  local bazel_major=""
  local bazel_minor=""
  local current
  local arg

  while [[ "$#" -ne  0 ]]; do
    current="$1"
    shift
    arg="${current#*=}"

    case "$current" in
    --bazelversion=*)
      bazelversion="$arg"
      ;;
    --skylib=*)
      skylib_version="$arg"
      ;;
    --platforms=*)
      platforms_version="$arg"
      ;;
    --protobuf=*)
      protobuf_version="$arg"
      ;;
    --rules_java=*)
      rules_java_version="$arg"
      ;;
    --rules_proto=*)
      rules_proto_version="$arg"
      ;;
    --protoc_toolchain)
      protoc_toolchain="true"
      ;;
    --legacy_api)
      legacy_api="true"
      ;;
    esac
  done

  echo "$bazelversion" >.bazelversion
  cp "${dir}/deps/test/BUILD.bazel.test" BUILD

  # Set up .bazelrc
  printf '%s\n' \
    'common --noenable_workspace --enable_bzlmod' \
    'common --enable_platform_specific_config' \
    'common:windows --worker_quit_after_build --enable_runfiles' >.bazelrc

  if [[ "$bazelversion" =~ ^([0-9]+)\.([0-9]+)\.[0-9]+.* ]]; then
    bazel_major="${BASH_REMATCH[1]}"
    bazel_minor="${BASH_REMATCH[2]}"
  else
    echo "can't parse --bazelversion: $bazelversion" >&2
    exit 1
  fi

  if [[ "$protoc_toolchain" == "true" ]]; then
    echo 'common --incompatible_enable_proto_toolchain_resolution' >>.bazelrc
  elif [[ "$bazel_major" == "7" ]]; then
    printf '%s\n' \
      'common:linux --cxxopt=-std=c++17' \
      'common:linux --host_cxxopt=-std=c++17' \
      'common:macos --cxxopt=-std=c++17' \
      'common:macos --host_cxxopt=-std=c++17' \
      'common:windows --cxxopt=/std=c++17' \
      'common:windows --host_cxxopt=/std=c++17' >>.bazelrc
  fi

  if [[ "$legacy_api" == "true" ]]; then
    echo 'common --experimental_google_legacy_api' >>.bazelrc
  fi

  if [[ "$bazel_major" == "7" && "$bazel_minor" -ge 3 ]]; then
    echo 'common --incompatible_use_plus_in_repo_names' >>.bazelrc
  fi

  # Set up the `protobuf` precompiled protocol compiler toolchain patch.
  if [[ "${protobuf_version:0:3}" =~ ^(29|30)\. ]]; then
    cp "${dir}/protoc/0001-protobuf-19679-rm-protoc-dep.patch" ./protobuf.patch
  else
    touch ./protobuf.patch
  fi

  # Render the MODULE.bazel file
  sed -e "s%\${bazelversion}%${bazelversion}%" \
    -e "s%\${skylib_version}%${skylib_version}%" \
    -e "s%\${platforms_version}%${platforms_version}%" \
    -e "s%\${protobuf_version}%${protobuf_version}%" \
    -e "s%\${rules_java_version}%${rules_java_version}%" \
    -e "s%\${rules_proto_version}%${rules_proto_version}%" \
    "${dir}/deps/test/MODULE.bazel.template" >MODULE.bazel

  # Copy files needed by the test targets
  cp \
    "${dir}"/deps/test/*.{scala,bzl} \
    "${dir}"/examples/testing/multi_frameworks_toolchain/example/*.scala \
    "${dir}"/test/jmh/{TestBenchmark.scala,data.txt} \
    "${dir}"/test/proto/standalone.proto \
    "${dir}"/test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2/thrift3/Thrift3.thrift \
    .

  set -e
  bazel build //...
  bazel test //...

  # Windows fails with:
  # FATAL: ExecuteProgram(C:\...\ScalafmtTest.format-test) failed:
  #   ERROR: src/main/native/windows/process.cc(202):
  #   CreateProcessW("C:\...\ScalafmtTest.format-test"):
  #   %1 is not a valid Win32 application.
  if ! is_windows; then
    bazel run //:ScalafmtTest.format-test
  fi
}

test_minimum_supported_versions() {
  do_build_and_test
}

test_bazel_7_with_rules_java_8() {
  do_build_and_test --rules_java=8.4.0
}

test_bazel_8() {
  do_build_and_test \
    --bazelversion=8.0.0 \
    --skylib=1.7.0 \
    --protobuf=29.0 \
    --rules_java=8.5.0 \
    --rules_proto=7.0.0
}

test_precompiled_protoc_rules_java_7() {
  do_build_and_test \
    --protoc_toolchain \
    --skylib=1.7.0 \
    --protobuf=29.0 \
    --rules_java=7.10.0 \
    --rules_proto=7.0.0 \
    --legacy_api
}

test_precompiled_protoc_rules_java_8_3_0() {
  do_build_and_test \
    --protoc_toolchain \
    --bazelversion=7.3.2 \
    --skylib=1.7.0 \
    --protobuf=29.0 \
    --rules_java=8.3.0 \
    --rules_proto=7.0.0
}

test_precompiled_protoc_rules_java_8_3_2() {
  do_build_and_test \
    --protoc_toolchain \
    --skylib=1.7.0 \
    --protobuf=29.0 \
    --rules_java=8.3.2 \
    --rules_proto=7.0.0
}

setup_suite
RULES_SCALA_TEST_REGEX="${RULES_SCALA_TEST_REGEX:-$windows_regex}" \
  run_tests "$test_source" "$(get_test_runner "${1:-local}")"
teardown_suite
