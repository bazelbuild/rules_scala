load("@rules_java//java:defs.bzl", "java_proto_library")
load("@rules_proto//proto:defs.bzl", "proto_library")

licenses(["notice"])

package(default_visibility = ["//visibility:public"])

FILES = [
    "worker_protocol",
]

[proto_library(
    name = s + "_proto",
    srcs = [s + ".proto"],
) for s in FILES]

[java_proto_library(
    name = s + "_java_proto",
    deps = [":" + s + "_proto"],
) for s in FILES]
