load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load(
    "@io_bazel_rules_scala//scala_proto/private:scala_proto_aspect_provider.bzl",
    "ScalaProtoAspectInfo",
)
load(
    "@io_bazel_rules_scala//scala/private:phases/api.bzl",
    "extras_phases",
    "run_phases",
)
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("//scala_proto/private:scala_proto_aspect.bzl", "make_scala_proto_aspect")

def phase_merge_aspect_java_info(ctx, p):
    java_info = java_common.merge([dep[ScalaProtoAspectInfo].java_info for dep in ctx.attr.deps])
    return struct(
        java_info = java_info,
        external_providers = {
            "JavaInfo": java_info,
        },
    )

def phase_default_info(ctx, p):
    java_info = p.merge_aspects.java_info
    output_jars = [jar.class_jar for jar in java_info.outputs.jars]
    source_jars = [jar.source_jar for jar in java_info.outputs.jars if jar.source_jar]
    return struct(
        external_providers = {
            "DefaultInfo": DefaultInfo(files = depset(output_jars + source_jars)),
        },
    )

def _scala_proto_library(ctx):
    return run_phases(
        ctx,
        [
            ("merge_aspects", phase_merge_aspect_java_info),
            ("default_info", phase_default_info),
        ],
    )

scala_proto_aspect = make_scala_proto_aspect()

def make_scala_proto_library(*extras, aspects = [scala_proto_aspect]):
    attrs = {
        "deps": attr.label_list(providers = [ProtoInfo], aspects = aspects),
    }
    return rule(
        implementation = _scala_proto_library,
        attrs = dicts.add(
            attrs,
            extras_phases(extras),
            *[extra["attrs"] for extra in extras if "attrs" in extra]
        ),
        fragments = ["java"],
        provides = [DefaultInfo, JavaInfo],
    )

scala_proto_library = make_scala_proto_library(
    aspects = [
        scala_proto_aspect,
    ],
)
