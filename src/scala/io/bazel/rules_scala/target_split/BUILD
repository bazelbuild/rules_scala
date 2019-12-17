load(":sculpt.bzl", "sculpt_json")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary")

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

