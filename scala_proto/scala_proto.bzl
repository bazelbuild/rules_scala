load("//private:console.bzl", "console_print_deprecation")
load("//scalapb:scalapb.bzl", "scalapb_repositories", _scalapb_proto_library = "scalapb_proto_library")

def scala_proto_repositories(**kwargs):
    console_print_deprecation(
        "//scala_proto:scala_proto.bzl scala_proto_repositories",
        "//scalapb:scalapb.bzl scalapb_repositories")
    scalapb_repositories(**kwargs)

def scalapb_proto_library(**kwargs):
    console_print_deprecation(
        "//scala_proto:scala_proto.bzl scalapb_proto_library",
        "//scalapb:scalapb.bzl scalapb_proto_library")
    _scalapb_proto_library(**kwargs)
