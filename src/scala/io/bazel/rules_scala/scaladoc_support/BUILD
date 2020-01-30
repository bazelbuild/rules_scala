load("//scala:scala.bzl", "scala_binary")

# A simple scala_binary to run scaladoc.
# `bazel run` this target with "-help" as a param for usage text:
# bazel run -- "//src/scala/io/bazel/rules_scala/scaladoc_support:scaladoc_generator" -help
scala_binary(
    name = "scaladoc_generator",
    main_class = "scala.tools.nsc.ScalaDoc",
    visibility = ["//visibility:public"],
    runtime_deps = [
        "//external:io_bazel_rules_scala/dependency/scala/parser_combinators",
        # "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        # "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        # "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
    ],
)
