load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "generator_lib",
    srcs = ["TwitterScroogeGenerator.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
        "//src/java/io/bazel/rulesscala/io_utils",
        "//src/java/io/bazel/rulesscala/jar",
        "//src/java/io/bazel/rulesscala/worker",
        "//src/scala/io/bazel/rules_scala/scrooge_support:compiler",
    ],
)

scala_binary(
    name = "generator",
    main_class = "scripts.ScroogeWorker",
    visibility = ["//visibility:public"],
    deps = [
        ":generator_lib",
    ],
)

scala_library(
    name = "scala_proto_request_extractor",
    srcs = ["PBGenerateRequest.scala"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "scalapb_generator_lib",
    srcs = ["ScalaPBGenerator.scala"],
    unused_dependency_checker_ignored_targets = [
        "//external:io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
    ],
    visibility = ["//visibility:public"],
    runtime_deps = [
        "//external:io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
    ],
    deps = [
        ":scala_proto_request_extractor",
        "//external:io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
        "//external:io_bazel_rules_scala/dependency/proto/protoc_bridge",
        "//external:io_bazel_rules_scala/dependency/proto/scalapb_plugin",
        "//external:io_bazel_rules_scala/dependency/proto/scalapbc",
        "//src/java/io/bazel/rulesscala/io_utils",
        "//src/java/io/bazel/rulesscala/jar",
        "//src/java/io/bazel/rulesscala/worker",
    ],
)

scala_binary(
    name = "scalapb_generator",
    main_class = "scripts.ScalaPBWorker",
    visibility = ["//visibility:public"],
    deps = [
        ":scalapb_generator_lib",
    ],
)
