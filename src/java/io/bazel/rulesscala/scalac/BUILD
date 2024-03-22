load("//src/java/io/bazel/rulesscala/scalac:scalac.bzl", "setup_scalac", "source_jar")

source_jar(
    name = "scalac_2",
    srcs = [
        "ReportableMainClass.java",
        "ScalacInvoker.java",
        "ScalacInvokerResults.java",
        "ScalacWorker.java",
    ],
    outs = "scalac_2.srcjar",
    visibility = ["//visibility:public"],
)

source_jar(
    name = "scalac_3",
    srcs = [
        "ScalacInvoker3.java",
        "ScalacInvokerResults.java",
        "ScalacWorker.java",
    ],
    outs = "scalac_3.srcjar",
    visibility = ["//visibility:public"],
)

setup_scalac()
