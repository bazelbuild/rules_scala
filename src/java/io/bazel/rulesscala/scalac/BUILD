load("@rules_java//java:defs.bzl", "java_binary", "java_test")

java_binary(
    name = "scalac",
    srcs = [
        ":scalac_files",
    ],
    javacopts = [
        "-source 1.8",
        "-target 1.8",
    ],
    main_class = "io.bazel.rulesscala.scalac.ScalacWorker",
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/io_utils",
        "//third_party/bazel/src/main/protobuf:worker_protocol_java_proto",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
        "@io_bazel_rules_scala//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)

filegroup(
    name = "scalac_files",
    srcs = [
        "CompileOptions.java",
        "ProtoReporter.java",
        "ReportableMainClass.java",
        "ScalacWorker.java",
    ],
    visibility = ["//visibility:public"],
)

java_test(
    name = "CompileOptionsTest",
    srcs = ["CompileOptionsTest.java"],
    test_class = "io.bazel.rulesscala.scalac.CompileOptionsTest",
    deps = [":scalac"],
)
