load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
)
load(
    "//scala_proto/private:scala_proto_default_repositories.bzl",
    "scala_proto_default_repositories",
)
load(
    "//scala_proto/private:scalapb_aspect.bzl",
    "ScalaPBAspectInfo",
    "scalapb_aspect",
)

def scala_proto_repositories(
        maven_servers = _default_maven_server_urls()):
    return scala_proto_default_repositories(maven_servers)

def _scala_proto_library_impl(ctx):
    java_info = java_common.merge([dep[ScalaPBAspectInfo].java_info for dep in ctx.attr.deps])
    default_info = DefaultInfo(files = java_info.full_compile_jars)
    return [default_info, java_info]

scala_proto_library = rule(
    implementation = _scala_proto_library_impl,
    attrs = {
        "deps": attr.label_list(aspects = [scalapb_aspect]),
    },
    provides = [DefaultInfo, JavaInfo],
)

def scalapb_proto_library(**kwargs):
    scala_proto_library(**kwargs)
