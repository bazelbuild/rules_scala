load("@rules_java//java:defs.bzl", "java_library")
load(
    "@io_bazel_rules_scala//scala:scala.bzl",
    "scala_library",
)

java_library(
    name = "commands",
    srcs = glob(["*.java"]),
    resource_strip_prefix = "tmp",
    resources = [
        "xxx/yyy.txt",
    ],
)

scala_library(
    name = "resources-scala",
    resource_strip_prefix = "tmp",
    resources = [ "xxx/yyy.txt","xxx/zzz/aaa.txt"],
)
