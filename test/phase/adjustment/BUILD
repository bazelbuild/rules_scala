load(
    "//test/phase/adjustment:phase_adjustment_test.bzl",
    "adjustment_replace_scala_library",
    "adjustment_replace_singleton",
    "adjustment_scala_library",
    "adjustment_singleton",
)

adjustment_singleton(
    name = "phase_adjustment",
    visibility = ["//visibility:public"],
)

adjustment_replace_singleton(
    name = "phase_adjustment_replace",
    visibility = ["//visibility:public"],
)

adjustment_scala_library(
    name = "PhaseLibrary",
    srcs = ["PhaseLibrary.scala"],
)

adjustment_replace_scala_library(
    name = "PhaseLibraryReplace",
    srcs = ["PhaseLibrary.scala"],
)
