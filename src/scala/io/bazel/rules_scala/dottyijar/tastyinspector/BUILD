load("@rules_java//java:defs.bzl", "java_binary")
load("//scala:scala.bzl", "scala_binary")

java_binary(
    name = "compiler",
    main_class = "dotty.tools.dotc.Main",
    runtime_deps = [
        "@io_bazel_rules_scala_scala_compiler_3_6_2",
        "@io_bazel_rules_scala_scala_library_3_6_2",
    ],
)

scala_binary(
    name = "tastyinspector",
    srcs = glob(["*.scala"]),
    data = [":compiler"],
    main_class = "io.bazel.rules_scala.dottyijar.tastyinspector.TastyInspector",
    scala_version = "3.6.2",
    deps = [
        "//src/scala/io/bazel/rules_scala/dottyijar/tasty",
        "//src/scala/io/bazel/rules_scala/dottyijar/tasty/format",
        "@dev_zio_izumi_reflect_3_6_2",
    ],
)
