load("@io_bazel_rules_scala_for_plugin_bootstrapping//scala:scala.bzl", "scala_library")

package(default_visibility = ["//visibility:public"])

scala_library(
    name = "resources",
    resources = native.glob(["**"],exclude=["BUILD"]),
    visibility = ["//visibility:public"],
)