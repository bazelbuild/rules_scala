java_binary(
    name = "scalac",
    srcs = [
        "CompileOptions.java",
        "ScalaCInvoker.java",
        "ScalacProcessor.java",
    ],
    main_class = "io.bazel.rulesscala.scalac.ScalaCInvoker",
    visibility = ["//visibility:public"],
    deps = [
        "//src/java/com/google/devtools/build/lib:worker",
        "//src/java/io/bazel/rulesscala/jar",
        "//src/java/io/bazel/rulesscala/worker",
        '//external:io_bazel_rules_scala/dependency/scala/scala_compiler',
        '//external:io_bazel_rules_scala/dependency/scala/scala_library',
        '//external:io_bazel_rules_scala/dependency/scala/scala_reflect',
    ],
)
