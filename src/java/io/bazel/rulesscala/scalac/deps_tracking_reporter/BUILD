load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION", "SCALA_MINOR_VERSION")

filegroup(
    name = "deps_tracking_reporter",
    srcs = [
        "before_2_13_12/DepsTrackingReporter.java",
    ] if SCALA_MAJOR_VERSION.startswith("2.11") or SCALA_MAJOR_VERSION.startswith("2.12") or (SCALA_MAJOR_VERSION.startswith("2.13") and int(SCALA_MINOR_VERSION) < 12) else [
        "after_2_13_12/DepsTrackingReporter.java",
    ],
    visibility = ["//visibility:public"],
)
