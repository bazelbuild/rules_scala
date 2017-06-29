load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "tut_compiler_lib",
    srcs = ["TutCompiler.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/tut/tut_core",
        "//src/java/io/bazel/rulesscala/io_utils",
    ],
)

scala_binary(
    name = "tut_compiler",
    main_class = "io.bazel.rules_scala.tut_support.TutCompiler",
    visibility = ["//visibility:public"],
    deps = [":tut_compiler_lib"],
)
