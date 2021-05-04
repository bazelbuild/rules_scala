load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "tut_compiler_lib",
    srcs = ["TutCompiler.scala"],
    visibility = ["//visibility:public"],
    runtime_deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
    ],
    deps = [
        "//src/java/io/bazel/rulesscala/io_utils",
        "@io_bazel_rules_scala//tut_rule:tut_core",
    ],
)

scala_binary(
    name = "tut_compiler",
    main_class = "io.bazel.rules_scala.tut_support.TutCompiler",
    visibility = ["//visibility:public"],
    deps = [":tut_compiler_lib"],
)
