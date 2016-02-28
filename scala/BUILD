load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

java_binary(
    name = "scala-worker",
    main_class = "com.databricks.bazel.ScalaWorker",
    visibility = ["//visibility:public"],
    runtime_deps = [
        ":scala-worker-lib-import",
        "@bazel_tools//src/main/protobuf:worker_protocol_proto",
        "@zinc_0_3_10_SNAPSHOT_jar//jar",
        "@scala_compiler_jar//jar",
        "@incremental_compiler_0_13_9_jar//jar",
        "@scala_library_jar//jar",
        "@scala_reflect_jar//jar",
        "@sbt_interface_0_13_9_jar//jar",
        "@compiler_interface_0_13_9_sources_jar//jar",
        "@nailgun_server_0_9_1_jar//jar",
    ],
)

java_import(
    name = "scala-worker-lib-import",
    jars = ["scala-worker-lib_deploy.jar"],
)

scala_library(
    name = "scala-worker-lib",
    srcs = glob(["ScalaWorker.scala"]),
    deps = [
        "@bazel_tools//src/main/protobuf:worker_protocol_proto",
        "@zinc_0_3_10_SNAPSHOT_jar//jar",
        "@scala_compiler_jar//jar",
        "@incremental_compiler_0_13_9_jar//jar",
        "@scala_library_jar//jar",
        "@scala_reflect_jar//jar",
        "@sbt_interface_0_13_9_jar//jar",
        "@compiler_interface_0_13_9_sources_jar//jar",
        "@nailgun_server_0_9_1_jar//jar",
    ],
)

