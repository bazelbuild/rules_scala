load("//scala:scala.bzl",
    "scala_binary",
    "scala_library")

scala_binary(
    name = "src_generator",
    srcs = ["SrcGenerator.scala"],
    main_class = "build.bazel.rulesscala.test.srcgen.SrcGenerator")

genrule(
    name = "foo",
    srcs = [],
    outs = ["foo.scala"],
    cmd = "./$(location src_generator) hello foo > \"$@\"",
    tools = ["src_generator"],
)

scala_binary(
    name = "uses_gen_file",
    srcs = ["foo.scala"],
    main_class = "Foo")
