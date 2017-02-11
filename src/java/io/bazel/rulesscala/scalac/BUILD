java_binary(name = "scalac",
  main_class = "io.bazel.rulesscala.scalac.ScalaCInvoker",
  srcs = ["ScalaCInvoker.java", "CompileOptions.java", "ScalacProcessor.java"],

  deps = [
    "@scala//:lib/scala-library.jar",
    "@scala//:lib/scala-reflect.jar",
    "@scala//:lib/scala-compiler.jar",
    "//src/java/io/bazel/rulesscala/jar",
    "//src/java/io/bazel/rulesscala/worker",
    "//src/java/com/google/devtools/build/lib:worker",
  ],
  visibility = ["//visibility:public"],
)
