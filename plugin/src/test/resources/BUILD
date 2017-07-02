load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

package(default_visibility = ["//visibility:public"])

scala_library(
    name = "resources",
    resources = native.glob(["**"],exclude=["BUILD"]),
    visibility = ["//visibility:public"],
)