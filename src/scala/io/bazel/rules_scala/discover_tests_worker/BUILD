load("//scala:defs.bzl", "scala_binary")

scala_binary(
	name = "discover_tests_worker",
	srcs = ["DiscoverTestsWorker.scala"],
        main_class = "io.bazel.rules_scala.discover_tests_worker.DiscoverTestsWorker",
	deps = [
	     "@io_bazel_rules_scala_classgraph//jar:jar",
	     "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
             "@io_bazel_rules_scala_test_interface//jar:jar",
            ":discovered_tests_java_proto",
            "//external:io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
	],
        visibility = ["//visibility:public"],
)

proto_library(
    name = "discovered_tests_proto",
    srcs = ["discovered_tests.proto"],
)

java_proto_library(
    name = "discovered_tests_java_proto",
    deps = [":discovered_tests_proto"],
    visibility = ["//visibility:public"],
)
