load("//private:console.bzl", "console_print_deprecation")

load("//scalapb:scalapb_toolchain.bzl", "scalapb_toolchain")

def scala_proto_toolchain(**kwargs):
    console_print_deprecation(
        "//scala_proto:scala_proto_toolchain.bzl scala_proto_toolchain",
        "//scalapb:scalapb_toolchain.bzl scalapb_toolchain")
    scalapb_toolchain(**kwargs)