load(
    "@rules_proto//proto:defs.bzl",
    "ProtoInfo",
)
load(
    "//scala_proto/private:proto_to_scala_src.bzl",
    "proto_to_scala_src",
)
load("//scala_proto/private:compile_proto.bzl", "compile_proto", "compiled_jar_file")

def _scala_proto_library_extended_impl(ctx):
    deps = [d[JavaInfo] for d in ctx.attr.deps]

    # we sort so the inputs are always the same for caching
    compile_protos = sorted(ctx.attr.proto[ProtoInfo].direct_sources)
    transitive_protos = sorted(ctx.attr.proto[ProtoInfo].transitive_sources.to_list())

    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala_proto:toolchain_type"]
    flags = []
    imps = [j[JavaInfo] for j in ctx.attr._implicit_compile_deps]

    if toolchain.with_grpc:
        flags.append("grpc")
        imps.extend([j[JavaInfo] for j in ctx.attr._grpc_deps])

    if toolchain.with_flat_package:
        flags.append("flat_package")

    if toolchain.with_single_line_to_string:
        flags.append("single_line_to_proto_string")

    extra_generator_jars = []
    for generator_dep in toolchain.extra_generator_dependencies:
        jinfo = generator_dep[JavaInfo]
        extra_generator_jars.extend(jinfo.transitive_runtime_jars.to_list())

    code_generator = toolchain.code_generator

    scalapb_file = ctx.actions.declare_file(
        ctx.attr.proto.label.name + "_scalapb.srcjar",
    )

    proto_to_scala_src(
        ctx,
        ctx.attr.proto.label,
        code_generator,
        compile_protos,
        transitive_protos,
        ctx.attr.proto[ProtoInfo].transitive_proto_path.to_list(),
        flags,
        scalapb_file,
        toolchain.named_generators,
        sorted(extra_generator_jars),
    )

    src_jars = depset([scalapb_file])
    output = compiled_jar_file(ctx.actions, scalapb_file)
    outs = depset([output])
    java_info = compile_proto(
        ctx,
        toolchain.scalac,
        ctx.attr.proto.label,
        output,
        scalapb_file,
        deps,
        imps,
        compile_protos,
        "" if ctx.attr.proto[ProtoInfo].proto_source_root == "." else ctx.attr.proto[ProtoInfo].proto_source_root,
    )
    return [
        java_info,
        DefaultInfo(files = outs),
    ]

scala_proto_library_extended = rule(
    implementation = _scala_proto_library_extended_impl,
    attrs = {
        "proto": attr.label(providers = [ProtoInfo]),
        "deps": attr.label_list(
            providers = [JavaInfo],
        ),
        "_protoc": attr.label(executable = True, cfg = "host", default = "@com_google_protobuf//:protoc"),
        "_implicit_compile_deps": attr.label_list(cfg = "target", default = [
            "//external:io_bazel_rules_scala/dependency/proto/implicit_compile_deps",
        ]),
        "_grpc_deps": attr.label_list(cfg = "target", default = [
            "//external:io_bazel_rules_scala/dependency/proto/grpc_deps",
        ]),
    },
    toolchains = [
        "@io_bazel_rules_scala//scala:toolchain_type",
        "@io_bazel_rules_scala//scala_proto:toolchain_type",
    ],
    provides = [DefaultInfo, JavaInfo],
)

def scalapb_proto_library_extended(**kwargs):
    scala_proto_library_extended(**kwargs)
