exports_files([
    "byes",
    "hellos",
    "more-byes",
    "more-hellos",
    "Foo.thrift",
    "Bar.thrift",
    "Baz.thrift",
])

genrule(
    name = "generated-hello",
    outs = ["generated-hello.txt"],
    cmd = "echo 'hello' > $@",
    visibility = ["//visibility:public"],
)
