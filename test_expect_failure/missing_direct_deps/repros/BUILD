load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "specs2_matcher_repro",
    srcs = ["Specs2MatchersRepro.scala"],
    deps = [
        # Repro code depends on specs2_fp via specs2_common: "@io_bazel_rules_scala_org_specs2_specs2_common",
        "@io_bazel_rules_scala_org_specs2_specs2_fp",
        "@io_bazel_rules_scala_org_specs2_specs2_matcher",
    ],
)
