load("@rules_java//java:defs.bzl", "java_binary")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

java_binary(
    name = "diagnostics_reporter_test",
    srcs = [
        "DiagnosticsReporterTest.java",
        "VerifyDiagnosticsOutput.java",
    ] + select_for_scala_version(
        any_2 = ["DiagnosticsReporterTestCases2.java"],
        any_3 = ["DiagnosticsReporterTestCases3.java"],
    ),
    main_class = "diagnostics_reporter.DiagnosticsReporterTest",
    visibility = ["//visibility:public"],
    deps = [
        "//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)
