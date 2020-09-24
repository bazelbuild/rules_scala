load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load("//scala_proto/private:proto_to_scala_src.bzl", "proto_to_scala_src")
load("//scala_proto/private:compile_proto.bzl", "compile_proto", "compiled_jar_file")

ScalaPBAspectInfo = provider(fields = [
    "proto_info",
    "src_jars",
    "output_files",
    "java_info",
])

ScalaPBImport = provider(fields = [
    "java_info",
    "proto_info",
])

ScalaPBInfo = provider(fields = [
    "aspect_info",
])

def merge_proto_infos(tis):
    return struct(
        transitive_sources = [t.transitive_sources for t in tis],
    )

def merge_scalapb_aspect_info(scalapbs):
    return ScalaPBAspectInfo(
        src_jars = depset(transitive = [s.src_jars for s in scalapbs]),
        output_files = depset(transitive = [s.output_files for s in scalapbs]),
        proto_info = merge_proto_infos([s.proto_info for s in scalapbs]),
        java_info = java_common.merge([s.java_info for s in scalapbs]),
    )

####
# This is applied to the DAG of proto_librarys reachable from a deps
# or a scalapb_scala_library. Each proto_library will be one scalapb
# invocation assuming it has some sources.
def _scalapb_aspect_impl(target, ctx):
    deps = [d[ScalaPBAspectInfo].java_info for d in ctx.rule.attr.deps]

    if ProtoInfo not in target:
        # We allow some dependencies which are not protobuf, but instead
        # are jvm deps. This is to enable cases of custom generators which
        # add a needed jvm dependency.
        java_info = target[JavaInfo]
        src_jars = depset()
        outs = depset()
        transitive_ti = merge_proto_infos(
            [
                d[ScalaPBAspectInfo].proto_info
                for d in ctx.rule.attr.deps
            ],
        )
    else:
        target_ti = target[ProtoInfo]
        transitive_ti = merge_proto_infos(
            [
                d[ScalaPBAspectInfo].proto_info
                for d in ctx.rule.attr.deps
            ] + [target_ti],
        )

        # we sort so the inputs are always the same for caching
        compile_protos = sorted(target_ti.direct_sources)
        transitive_protos = sorted(target_ti.transitive_sources.to_list())

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

        # This feels rather hacky and odd, but we can't compare the labels to ignore a target easily
        # since the @ or // forms seem to not have good equality :( , so we aim to make them absolute
        #
        # the backlisted protos in the tool chain get made into to absolute paths
        # so we make the local target we are looking at absolute too
        target_absolute_label = target.label
        if not str(target_absolute_label)[0] == "@":
            target_absolute_label = Label("@%s//%s:%s" % (ctx.workspace_name, target.label.package, target.label.name))

        for lbl in toolchain.blacklisted_protos:
            if (lbl.label == target_absolute_label):
                compile_protos = False

        code_generator = toolchain.code_generator

        if compile_protos:
            scalapb_file = ctx.actions.declare_file(
                target.label.name + "_scalapb.srcjar",
            )
            proto_to_scala_src(
                ctx,
                target.label,
                code_generator,
                compile_protos,
                transitive_protos,
                target_ti.transitive_proto_path.to_list(),
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
                target.label,
                output,
                scalapb_file,
                deps,
                imps,
                compile_protos,
                "" if target_ti.proto_source_root == "." else target_ti.proto_source_root,
            )
        else:
            # this target is only an aggregation target
            src_jars = depset()
            outs = depset()
            java_info = java_common.merge(_concat_lists(deps, imps))

    return [
        ScalaPBAspectInfo(
            src_jars = src_jars,
            output_files = outs,
            proto_info = transitive_ti,
            java_info = java_info,
        ),
    ]

def _concat_lists(list1, list2):
    all_providers = []
    all_providers.extend(list1)
    all_providers.extend(list2)
    return all_providers

scalapb_aspect = aspect(
    implementation = _scalapb_aspect_impl,
    attr_aspects = ["deps"],
    required_aspect_providers = [
        [ProtoInfo],
        [ScalaPBImport],
    ],
    attrs = {
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
)
