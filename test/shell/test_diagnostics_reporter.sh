# Diagnostics Reporters Tests. Diagnostics definition based off the definition provided by the LSP

# shellcheck source=./test_runner.sh
dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

build_target() {
  target=$1
  bazel build --build_event_publish_all_actions //test_expect_failure/diagnostics_reporter:"$target" || true
}

verify_output() {
  target=$1
  expected_outputs=$2
  execution_root=$(bazel info execution_root)
  output=$("$execution_root/bazel-out/host/bin/external/com_google_protobuf/protoc" --decode_raw < "$execution_root"/bazel-out/darwin-fastbuild/bin/test_expect_failure/diagnostics_reporter/"$target".diagnosticsproto)
  for expected_output in "${expected_outputs[*]}"; do
    if [[ "$output" != *"$expected_output"* ]]; then
      echo "Expected: $expected_output, got: $output"
      exit 1
    fi
  done

}

verify_simple_file() {
  build_target "error_file"
  outputs=("1 {
  1: \"workspace-root://test_expect_failure/diagnostics_reporter/ErrorFile.scala\"
  2 {
    1 {
      1 {
        1: 5
        2: 2
      }
      2 {
        1: 6
      }
    }
    2: 1
    5: \"\')\' expected but \'}\' found.\"
  }
}")
  verify_output "error_file" "${outputs[@]}"
}

verify_two_errors_file() {
  build_target "two_errors_file"
  outputs=("1: \"workspace-root://test_expect_failure/diagnostics_reporter/TwoErrorsFile.scala\"
  2 {
    1 {
      1 {
        1: 4
        2: 4
      }
      2 {
        1: 5
      }
    }
    2: 1
    5: \"not found: value printn\"
  }" "1: \"workspace-root://test_expect_failure/diagnostics_reporter/TwoErrorsFile.scala\"
  2 {
    1 {
      1 {
        1: 4
        2: 4
      }
      2 {
        1: 5
      }
    }
    2: 1
    5: \"not found: value printn\"
  }
  2 {
    1 {
      1 {
        1: 5
        2: 4
      }
      2 {
        1: 6
      }
    }
    2: 1
    5: \"not found: value prinf\"
  }")
  verify_output "two_errors_file" "${outputs[@]}"
}

verify_warning_file() {
  build_target "warning_file"
  outputs=("1 {
  1: \"workspace-root://test_expect_failure/diagnostics_reporter/WarningFile.scala\"
  2 {
    1 {
      1: \"\"
      2 {
        2: 7
      }
    }
    2: 2
    5: \"Unused import\"
  }
}")
  verify_output "warning_file" "${outputs[@]}"
}


verify_error_and_warning_file() {
  build_target "error_and_warning_file"
  outputs=("2 {
    1 {
      1: \"\"
      2 {
        2: 7
      }
    }
    2: 2
    5: \"Unused import\"
  }
}" "2 {
    1 {
      1 {
        1: 4
        2: 4
      }
      2 {
        1: 5
      }
    }
    2: 1
    5: \"not found: value printn\"
  }")
  verify_output "error_and_warning_file" "${outputs[@]}"
}


verify_info_file() {
  build_target "info_file"
  outputs=("2 {
    1 {
      1 {
        1: 18446744073709551615
        2: 18446744073709551615
      }
      2: \"\"
    }
    2: 3
    5: \"[running phase parser on InfoFile.scala]\"
  }")
  verify_output "info_file" "${outputs[@]}"
}

$runner verify_simple_file
$runner verify_two_errors_file
$runner verify_warning_file
$runner verify_error_and_warning_file
$runner verify_info_file
