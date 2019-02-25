load(
    "//scala/private:common.bzl",
    "write_manifest_file",
)
load("//scala/private:rule_impls.bzl", "compile_scala")

load("//scala_proto/private:proto_to_scala_src.bzl", "proto_to_scala_src")
load("//scala_proto/private:dep_sets.bzl", "SCALAPB_DEPS", "GRPC_DEPS")


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



def lift_proto_to_struct(tis):
    return struct(
        direct_sources = tis.direct_sources,
        transitive_sources = tis.transitive_sources,
        # transitive = depset(transitive = [t.transitive for t in tis]),
        # srcs = depset(transitive = [t.srcs for t in tis]),
        # import_flags = [t.import_flags for t in tis],
        # deps = depset(transitive = [t.deps for t in tis]),
    )

def merge_proto_infos(tis):
    return struct(
        transitive_sources = [t.transitive_sources for t in tis],
        # transitive = depset(transitive = [t.transitive for t in tis]),
        # srcs = depset(transitive = [t.srcs for t in tis]),
        # import_flags = [t.import_flags for t in tis],
        # deps = depset(transitive = [t.deps for t in tis]),
    )


def merge_scalapb_aspect_info(scalapbs):
    return ScalaPBAspectInfo(
        src_jars = depset(transitive = [s.src_jars for s in scalapbs]),
        output_files = depset(transitive = [s.output_files for s in scalapbs]),
        proto_info = merge_proto_infos([s.proto_info for s in scalapbs]),
        java_info = java_common.merge([s.java_info for s in scalapbs]),
    )


def _compiled_jar_file(actions, scalapb_jar):
    scalapb_jar_name = scalapb_jar.basename

    # ends with .srcjar, so remove last 6 characters
    without_suffix = scalapb_jar_name[0:len(scalapb_jar_name) - 6]

    # this already ends with _scalapb because that is how scalapb_jar is named
    compiled_jar = without_suffix + "jar"
    return actions.declare_file(compiled_jar, sibling = scalapb_jar)

def _compile_scala(
        ctx,
        label,
        output,
        scalapb_jar,
        deps_java_info,
        implicit_deps):
    manifest = ctx.actions.declare_file(
        label.name + "_MANIFEST.MF",
        sibling = scalapb_jar,
    )
    write_manifest_file(ctx.actions, manifest, None)
    statsfile = ctx.actions.declare_file(
        label.name + "_scalac.statsfile",
        sibling = scalapb_jar,
    )
    print("Compiling %s -> %s" %(label, scalapb_jar))
    merged_deps = java_common.merge(deps_java_info + implicit_deps)

    # this only compiles scala, not the ijar, but we don't
    # want the ijar for generated code anyway: any change
    # in the thrift generally will change the interface and
    # method bodies
    compile_scala(
        ctx,
        Label("%s-fast" % (label)),
        output,
        manifest,
        statsfile,
        sources = [],
        cjars = merged_deps.transitive_compile_time_jars,
        all_srcjars = depset([scalapb_jar]),
        transitive_compile_jars = merged_deps.transitive_compile_time_jars,
        plugins = [],
        resource_strip_prefix = "",
        resources = [],
        resource_jars = [],
        labels = {},
        in_scalacopts = [],
        print_compile_time = False,
        expect_java_output = False,
        scalac_jvm_flags = [],
        scalac = ctx.attr._scalac,
    )

    return JavaInfo(
        source_jar = scalapb_jar,
        deps = deps_java_info + implicit_deps,
        runtime_deps = deps_java_info + implicit_deps,
        exports = deps_java_info + implicit_deps,
        output_jar = output,
        compile_jar = output,
    )

def _empty_java_info(deps_java_info, implicit_deps):
    merged_deps = java_common.merge(deps_java_info + implicit_deps)
    return java_common.create_provider(
        use_ijar = False,
        compile_time_jars = depset(transitive = [merged_deps.compile_jars]),
        transitive_compile_time_jars = depset(
            transitive = [merged_deps.transitive_compile_time_jars],
        ),
        transitive_runtime_jars = depset(
            transitive = [merged_deps.transitive_runtime_jars],
        ),
    )

####
# This is applied to the DAG of thrift_librarys reachable from a deps
# or a scalapb_scala_library. Each thrift_library will be one scalapb
# invocation assuming it has some sources.
def _scalapb_aspect_impl(target, ctx):
    target_ti = target[ProtoInfo]

    deps = [d[ScalaPBAspectInfo].java_info for d in ctx.rule.attr.deps]
    transitive_ti = merge_proto_infos(
        [
            d[ScalaPBAspectInfo].proto_info
            for d in ctx.rule.attr.deps
        ] + [target_ti],
    )

    # we sort so the inputs are always the same for caching
    compile_protos = sorted(target_ti.direct_sources)
    transitive_protos = sorted(target_ti.transitive_sources)

    print("transitive_descriptor_sets")
    print(target_ti.transitive_descriptor_sets)
    print("target_ti.transitive_sources")
    print(target_ti.transitive_sources)
    print("transitive_imports")
    print(target_ti.transitive_imports)
    print("transitive_proto_path")
    print(target_ti.transitive_proto_path)
    print("proto_source_root")
    print(target_ti.proto_source_root)

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

    # if toolchain.with_java:
    #     flags.append("java_conversions")

    if compile_protos:
        # we sort so the inputs are always the same for caching
        compile_proto_map = {}
        for ct in compile_protos:
            compile_proto_map[ct] = True
        include_thrifts = sorted([
            trans
            for trans in compile_protos
            if trans not in compile_proto_map
        ])
        scalapb_file = ctx.actions.declare_file(
            target.label.name + "_scalapb.srcjar",
        )
        proto_to_scala_src(
            ctx,
            target.label,
            compile_protos,
            transitive_protos,
            target_ti.transitive_proto_path.to_list(),
            flags,
            scalapb_file,
        )

        src_jars = depset([scalapb_file])
        output = _compiled_jar_file(ctx.actions, scalapb_file)
        outs = depset([output])
        java_info = _compile_scala(
            ctx,
            target.label,
            output,
            scalapb_file,
            deps,
            imps,
        )
    else:
        # this target is only an aggregation target
        src_jars = depset()
        outs = depset()
        java_info = _empty_java_info(deps, imps)

    return [
        ScalaPBAspectInfo(
            src_jars = src_jars,
            output_files = outs,
            proto_info = transitive_ti,
            java_info = java_info,
        ),
    ]

scalapb_aspect = aspect(
    implementation = _scalapb_aspect_impl,
    attr_aspects = ["deps"],
    attrs = {
        "_pluck_scalapb_scala": attr.label(
            executable = True,
            cfg = "host",
            default = Label("@io_bazel_rules_scala//src/scala/scripts:scalapb_generator"),
            allow_files = True,
        ),
        "_scalac": attr.label(
            default = Label(
                "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac",
            ),
        ),
        "_grpc_deps": attr.label_list(
            providers = [JavaInfo],
            default = GRPC_DEPS
        ),
        "_implicit_compile_deps": attr.label_list(
            providers = [JavaInfo],
            default = SCALAPB_DEPS + [
            Label(
                    "//external:io_bazel_rules_scala/dependency/scala/scala_library",
                )
            ],
        ),
    },
    required_aspect_providers = [
        ["proto"],
        [ScalaPBImport],
    ],
    toolchains = [
        "@io_bazel_rules_scala//scala:toolchain_type",
        "@io_bazel_rules_scala//scala_proto:toolchain_type",
    ],
)
