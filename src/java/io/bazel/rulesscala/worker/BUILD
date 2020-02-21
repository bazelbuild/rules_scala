java_library(
    name = "worker",
    srcs = ["Worker.java"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//third_party/bazel/src/main/protobuf:worker_protocol_java_proto",
    ],
)

java_test(
    name = "worker_test",
    srcs = [
        "WorkerTest.java",
    ],
    test_class = "io.bazel.rulesscala.worker.WorkerTest",
    deps = [
        ":worker",
    ],
)
