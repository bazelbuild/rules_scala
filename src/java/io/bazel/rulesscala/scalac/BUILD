java_binary(name = "scalac",
  main_class = "io.bazel.rulesscala.scalac.ScalaCInvoker",
  srcs = ["ScalaCInvoker.java", "CompileOptions.java"],

  deps = [
    "@scala//:lib/scala-library.jar",
    "@scala//:lib/scala-reflect.jar",
    "@scala//:lib/scala-compiler.jar",
    "@scala//:lib/scala-xml_2.11-1.0.4.jar",
    "//src/java/io/bazel/rulesscala/jar",
    "@io_bazel//src/main/protobuf:worker_protocol_java_proto",
    "@io_bazel//third_party:guava",
  ],
  visibility = ["//visibility:public"],
)
