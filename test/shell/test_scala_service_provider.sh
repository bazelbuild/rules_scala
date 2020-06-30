# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

test_scala_service_provider_should_produce_expected_files() {
  services_jar='lib_with_scala_services.jar'
  services_file='META-INF/services/com.scala.test.service'
  services_target="//test:lib_with_scala_services"
  bazel build $services_target
  unzip -p bazel-bin/test/$services_jar $services_file > services.txt
  diff services.txt test/example_jars/expected_services.txt
  RESPONSE_CODE=$?
  rm services.txt
  exit $RESPONSE_CODE
}

$runner test_scala_service_provider_should_produce_expected_files
