load("//scala_proto/default:repositories.bzl", "scala_proto_default_repositories")
load(
    "//scala_proto/private:scala_proto.bzl",
    _make_scala_proto_library = "make_scala_proto_library",
    _scala_proto_library = "scala_proto_library",
)
load(
    "//scala_proto/private:scala_proto_aspect.bzl",
    _make_scala_proto_aspect = "make_scala_proto_aspect",
)

make_scala_proto_library = _make_scala_proto_library

make_scala_proto_aspect = _make_scala_proto_aspect

def scala_proto_repositories(**kwargs):
    scala_proto_default_repositories(**kwargs)

def scala_proto_library(**kwargs):
    _scala_proto_library(**kwargs)

def scalapb_proto_library(**kwargs):
    """
    Deprecated:
        Use scala_proto_library
    """
    _scala_proto_library(**kwargs)
