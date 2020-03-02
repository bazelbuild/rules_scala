load("@rules_java//java:defs.bzl", "java_binary", "java_library")

java_library(
    name = "exe-lib",
    srcs = [
        "LaunchInfo.java",
        "LauncherFileWriter.java",
    ],
    visibility = ["//visibility:private"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/guava",
        "@bazel_tools//tools/java/runfiles",
    ],
)

java_binary(
    name = "exe",
    data = [
        "@bazel_tools//tools/launcher",
    ],
    main_class = "io.bazel.rulesscala.exe.LauncherFileWriter",
    visibility = ["//visibility:public"],
    runtime_deps = [
        ":exe-lib",
    ],
)
