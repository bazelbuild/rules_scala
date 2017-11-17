exports_files(["byes", "hellos", "hellos-and-byes.jar", "more-byes", "more-hellos", "welcomes"])

genrule(
    name = "generated-hello",
    outs = ["generated-hello.txt"],
    cmd = "echo 'hello' > $@",
    visibility = ["//visibility:public"],
)
