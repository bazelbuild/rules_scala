load("@rules_java//java:defs.bzl", "java_binary")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION", "SCALA_MINOR_VERSION")

java_binary(
    name = "diagnostics_reporter_test",
    srcs = [
        "DiagnosticsReporterTest.java",
        "VerifyDiagnosticsOutput.java",
    ],
    main_class = "diagnostics_reporter.DiagnosticsReporterTest",
    visibility = ["//visibility:public"],
    deps = [
        "//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)
