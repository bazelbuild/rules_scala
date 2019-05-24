java_library(
    name = "exe-lib",
    srcs = [
        "LauncherFileWriter.java",
        "LaunchInfo.java",
    ],
    deps = [
        "@bazel_tools//tools/java/runfiles",
        "//external:io_bazel_rules_scala/dependency/scala/guava",
    ],
    visibility = ["//visibility:private"],
)

java_binary(
    name = "exe",
    main_class = "io.bazel.rulesscala.exe.LauncherFileWriter",
    runtime_deps = [
        ":exe-lib",
    ],
    data = [
        "@bazel_tools//tools/launcher",
    ],
    visibility = ["//visibility:public"],
)
