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
        "@scala//:scala-compiler",
        "@scala//:scala-library",
        "@scala//:scala-reflect",
    ],
)
