load("@rules_java//java:defs.bzl", "java_binary")

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
