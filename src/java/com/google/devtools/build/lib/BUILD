java_library(
    name = "worker",
    srcs = ["WorkerProtocol.java"],
    visibility = ["//visibility:public"],
    deps = [
      "@scalac_rules_protobuf_java//jar",
    ],
    exports = [
      "@scalac_rules_protobuf_java//jar",
    ],
)
filegroup(
    name = "sources",
    data = glob(["**"]),
    visibility = ["//visibility:public"]
    )