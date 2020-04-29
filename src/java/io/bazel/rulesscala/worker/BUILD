java_library(
    name = "worker",
    srcs = ["Worker.java"],
    visibility = ["//visibility:public"],
    deps = [
        "//third_party/bazel/src/main/protobuf:worker_protocol_java_proto",
    ],
)

java_test(
    name = "worker_test",
    srcs = [
        "WorkerTest.java",
    ],
    jvm_flags = [
        "-Dcom.google.testing.junit.runner.shouldInstallTestSecurityManager=false",
    ],
    test_class = "io.bazel.rulesscala.worker.WorkerTest",
    deps = [
        ":worker",
        "//third_party/bazel/src/main/protobuf:worker_protocol_java_proto",
    ],
)
