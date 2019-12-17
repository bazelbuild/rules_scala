load(":sculpt.bzl", "sculpt_json")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library")

sculpt_json(
    name = "example",
    srcs = ["File1.scala", "File2.scala"],
    deps = [
      "@io_bazel_rules_scala_scala_library",
      "@io_bazel_rules_scala_scala_compiler",
      "@io_bazel_rules_scala_scala_reflect",
    ],
    )

java_binary(
    name = "scalac_runner",
    runtime_deps = [
      "@io_bazel_rules_scala_scala_library",
      "@io_bazel_rules_scala_scala_compiler",
      "@io_bazel_rules_scala_scala_reflect",
      "@io_bazel_rules_scala_spray_json",
    ],
    main_class = "scala.tools.nsc.Main",
    visibility = ["//visibility:public"],
    )

scala_library(
    name = "dagify",
    srcs = ["Dagify.scala"],
    )

scala_library(
    name = "sculpt_processor",
    srcs = ["SculptProcessor.scala"],
    deps = [
      ":dagify",
      "@io_bazel_rules_scala_spray_json",
      "@sculpt//:sculpt",
    ])

java_binary(
    name = "sculpt_processor_runner",
    runtime_deps = [":sculpt_processor"],
    main_class = "io.bazel.rules_scala.target_split.SculptProcessor",
    )
