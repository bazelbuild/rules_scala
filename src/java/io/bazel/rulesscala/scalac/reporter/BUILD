java_library(
    name = "reporter",
    srcs = ["DepsTrackingReporter.java"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/scalac/compileoptions",
        ":scala_deps_java_proto",
    ],
)

proto_library(
    name = "scala_deps_proto",
    srcs = ["scala_deps.proto"],
    visibility = ["//visibility:public"],
)

java_proto_library(
    name = "scala_deps_java_proto",
    deps = [":scala_deps_proto"],
    visibility = ["//visibility:public"],
)

java_binary(
    name = "sdeps_reader",
    main_class = "io.bazel.rulesscala.scalac.reporter.ScalaDepsReader",
    srcs = ["ScalaDepsReader.java"],
    deps = [":scala_deps_java_proto"],
)