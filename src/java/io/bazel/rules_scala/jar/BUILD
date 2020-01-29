java_library(
    name = "jar",
    srcs = [
        "JarCreator.java",
        "JarHelper.java",
    ],
    visibility = ["//visibility:public"],
)

java_binary(
    name = "binary",
    main_class = "io.bazel.rules_scala.jar.JarCreator",
    visibility = ["//visibility:public"],
    runtime_deps = [
        ":jar",
    ],
)
