load(
    "@com_google_protobuf//bazel/toolchains:proto_toolchain.bzl",
    "proto_toolchain",
)
load("@rules_scala_toolchains//protoc:platforms.bzl", "PROTOC_PLATFORMS")

[
    proto_toolchain(
        name = platform,
        exec_compatible_with = specs,
        proto_compiler = "@rules_scala_toolchains//protoc:" + platform,
    )
    for platform, specs in PROTOC_PLATFORMS.items()
]
