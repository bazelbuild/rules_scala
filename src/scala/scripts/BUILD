load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "scrooge_worker_lib",
    srcs = ["ScroogeWorker.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//src/java/io/bazel/rulesscala/io_utils",
        "//src/java/io/bazel/rulesscala/jar",
        "//src/java/io/bazel/rulesscala/worker",
        "//src/scala/io/bazel/rules_scala/scrooge_support:compiler",
        "//twitter_scrooge:scrooge_generator_classpath",
    ],
)

scala_binary(
    name = "scrooge_worker",
    main_class = "scripts.ScroogeWorker",
    visibility = ["//visibility:public"],
    deps = [
        ":scrooge_worker_lib",
    ],
)

scala_library(
    name = "scalapb_worker_lib",
    srcs = ["ScalaPBWorker.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala_proto:scalapb_worker_deps",
        "//src/java/io/bazel/rulesscala/worker",
    ],
)

scala_binary(
    name = "scalapb_worker",
    main_class = "scripts.ScalaPBWorker",
    visibility = ["//visibility:public"],
    deps = [
        ":scalapb_worker_lib",
    ],
)
