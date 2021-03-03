load("@rules_java//java:defs.bzl", "java_binary")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary")

package(default_visibility = ["//visibility:public"])

alias(
    name = "jdk8",
    actual = select(
        {
            "@bazel_tools//src/conditions:linux_x86_64": "@jdk8_linux//:jdk",
            "@bazel_tools//src/conditions:darwin_x86_64": "@jdk8_macos//:jdk",
        },
        no_match_error = "Could not find a JDK for environment",
    ),
)

alias(
    name = "jdk11",
    actual = select(
        {
            "@bazel_tools//src/conditions:linux_x86_64": "@jdk11_linux//:jdk",
            "@bazel_tools//src/conditions:darwin_x86_64": "@jdk11_macos//:jdk",
        },
        no_match_error = "Could not find a JDK for environment",
    ),
)

java_binary(
    name = "MainJava",
    srcs = ["Main.java"],
    main_class = "examples.jdk.Main",
)

scala_binary(
    name = "MainScala",
    srcs = ["Main.scala"],
    main_class = "examples.jdk.Main",
)
