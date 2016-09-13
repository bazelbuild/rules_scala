java_library(name = "jar",
  srcs = ["JarCreator.java", "JarHelper.java"],
  visibility = ["//visibility:public"],
)


java_binary(name = "binary",
  runtime_deps = [
    ":jar",
  ],
  main_class = "io.bazel.rulesscala.jar.JarCreator",
  visibility = ["//visibility:public"],
)
