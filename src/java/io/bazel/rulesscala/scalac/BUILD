java_binary(
    name = "scalac",
    srcs = [
        "CompileOptions.java",
        "ScalaCInvoker.java",
        "ScalacProcessor.java",
        "Resource.java",
    ],
    main_class = "io.bazel.rulesscala.scalac.ScalaCInvoker",
    # this probably should be set globally for the entire rules_scala
    # but I don't know how to do it
    javacopts = [
    "-source 1.8",
    "-target 1.8"
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//src/java/com/google/devtools/build/lib:worker",
        "//src/java/io/bazel/rulesscala/jar",
        "//src/java/io/bazel/rulesscala/worker",
        '//external:io_bazel_rules_scala/dependency/commons_io/commons_io',
        '//external:io_bazel_rules_scala/dependency/scala/scala_compiler',
        '//external:io_bazel_rules_scala/dependency/scala/scala_library',
        '//external:io_bazel_rules_scala/dependency/scala/scala_reflect',
    ],
)
