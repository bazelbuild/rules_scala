load("@rules_java//java:defs.bzl", "java_binary")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION", "SCALA_MINOR_VERSION")

java_binary(
    name = "diagnostics_reporter_test",
    srcs = [
        "before_2_12_13/DiagnosticsReporterTest.java",
        "VerifyDiagnosticsOutput.java",
    ] if (SCALA_MAJOR_VERSION == "2.11") or ((SCALA_MAJOR_VERSION == "2.12") and int(SCALA_MINOR_VERSION) < 13) else [
        "after_2_12_13/DiagnosticsReporterTest.java",
        "VerifyDiagnosticsOutput.java",
    ],
    main_class = "diagnostics_reporter.DiagnosticsReporterTest",
    visibility = ["//visibility:public"],
    deps = [
        "//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)
