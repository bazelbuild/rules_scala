load("@rules_java//java:defs.bzl", "java_library")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//jmh:jmh.bzl", "scala_benchmark_jmh")
load("//scala:scala.bzl", "scala_library", "scala_test")

java_library(
    name = "java_type",
    srcs = ["JavaType.java"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "scala_type",
    srcs = ["ScalaType.scala"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "add_numbers",
    srcs = ["AddNumbers.scala"],
    visibility = ["//visibility:public"],
    exports = [
        ":java_type",
        ":scala_type",
    ],
    deps = [
        ":java_type",
        ":scala_type",
    ],
)

scala_library(
    name = "add_numbers_testonly",
    testonly = True,
    srcs = ["AddNumbers.scala"],
    visibility = ["//visibility:public"],
    exports = [
        ":java_type",
        ":scala_type",
    ],
    deps = [
        ":java_type",
        ":scala_type",
    ],
)

scala_benchmark_jmh(
    name = "test_benchmark",
    srcs = ["TestBenchmark.scala"],
    data = ["data.txt"],
    deps = [":add_numbers"],
)

scala_benchmark_jmh(
    name = "test_jmh_jdk8",
    srcs = ["TestJmhRuntimeJdk8.scala"],
    runtime_jdk = select({
        "@bazel_tools//src/conditions:darwin": "@remote_jdk8_macos//:jdk",
        "@bazel_tools//src/conditions:windows": "@remote_jdk8_windows//:jdk",
        "//conditions:default": "@remote_jdk8_linux//:jdk",
    }),
)

scala_benchmark_jmh(
    name = "test_jmh_jdk11",
    srcs = ["TestJmhRuntimeJdk11.scala"],
    runtime_jdk = "@rules_java//toolchains:remote_jdk11",
)

[sh_test(
    name = "Run" + "".join([binary[idx] if binary[idx].isalnum() else "_" for idx in range(len(binary))]),
    srcs = ["test_binary.sh"],
    args = ["$(location %s)" % binary],
    data = [binary if (":" in binary) else (":%s" % binary)],
) for binary in [
    "//test/jmh:test_jmh_jdk8",
    "//test/jmh:test_jmh_jdk11",
]]

scala_benchmark_jmh(
    name = "test_benchmark_testonly",
    testonly = True,
    srcs = ["TestBenchmark.scala"],
    data = ["data.txt"],
    deps = [":add_numbers_testonly"],
)

scala_test(
    name = "jmh_command_line_parsing_test",
    args = ["-h"],
    main_class = "org.openjdk.jmh.Main",
    deps = [":test_benchmark"],
)
