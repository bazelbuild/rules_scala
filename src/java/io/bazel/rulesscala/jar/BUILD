load("@rules_java//java:defs.bzl", "java_binary", "java_library")

java_library(
    name = "jar",
    srcs = [
        "JarCreator.java",
        "JarHelper.java",
    ],
    visibility = ["//visibility:public"],
)

java_binary(
    name = "binary",
    main_class = "io.bazel.rulesscala.jar.JarCreator",
    visibility = ["//visibility:public"],
    runtime_deps = [
        ":jar",
    ],
)
