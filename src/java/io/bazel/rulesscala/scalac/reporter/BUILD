load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_java//java:defs.bzl", "java_proto_library")
load("//src/java/io/bazel/rulesscala/scalac:scalac.bzl", "source_jar")

proto_library(
    name = "scala_deps_proto",
    srcs = ["scala_deps.proto"],
    visibility = ["//visibility:public"],
)

java_proto_library(
    name = "scala_deps_java_proto",
    visibility = ["//visibility:public"],
    deps = [":scala_deps_proto"],
)

[
    source_jar(
        name = d,
        srcs = glob(["%s/*.java" % d]),
        outs = "%s.srcjar" % d,
        visibility = ["//visibility:public"],
    )
    for d in [
        "after_2_12_13_and_before_2_13_12",
        "after_2_13_12",
        "before_2_12_13",
    ]
]

source_jar(
    name = "scala_3",
    srcs = ["PlaceholderForEmptyScala3Lib.java"],
    outs = "scala_3.srcjar",
    visibility = ["//visibility:public"],
)
