proto_library(
    name = "test",
    srcs = ["test.proto"],
    visibility = ["//visibility:public"],
)

proto_library(
    name = "test2",
    deps = [":test"],
    srcs = ["test2.proto"],
    visibility = ["//visibility:public"],
)

proto_library(
    name = "test3",
    deps = [":test"],
    srcs = ["test3.proto"],
    visibility = ["//visibility:public"],
)
