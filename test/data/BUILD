exports_files(["some.txt", "more.txt", "foo.txt"])

filegroup(
    name = "sources",
    data = glob(["**"]),
    visibility = ["//visibility:public"]
    )