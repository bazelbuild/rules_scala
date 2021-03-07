load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load(
    "@io_bazel_rules_scala//scala_proto/private:scala_proto_aspect_provider.bzl",
    "ScalaProtoAspectInfo",
)
load("//scala_proto/private:scala_proto_aspect.bzl", "scala_proto_aspect")

def _scala_proto_library_impl(ctx):
    java_info = java_common.merge([dep[ScalaProtoAspectInfo].java_info for dep in ctx.attr.deps])
    default_info = DefaultInfo(files = depset(java_info.source_jars, transitive = [java_info.full_compile_jars]))
    return [default_info, java_info]

scala_proto_library = rule(
    implementation = _scala_proto_library_impl,
    attrs = {
        "deps": attr.label_list(providers = [ProtoInfo], aspects = [scala_proto_aspect]),
    },
    provides = [DefaultInfo, JavaInfo],
)
