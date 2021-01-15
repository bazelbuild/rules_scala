cc_library(
    name = "hello-jni-lib",
    srcs = ["Hello.cc"],
    hdrs = ["Hello.h"],
    deps = [
        "@bazel_tools//tools/jdk:jni",
    ],
    alwayslink = True,
)

cc_binary(
    name = "hello-jni",
    linkshared = True,
    visibility = ["//visibility:public"],
    deps = [":hello-jni-lib"],
)
