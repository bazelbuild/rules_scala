load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load("//scala/private:common.bzl", "write_manifest_file")
load("//scala/private:dependency.bzl", "legacy_unclear_dependency_info_for_protobuf_scrooge")
load("//scala/private:rule_impls.bzl", "compile_scala")
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "find_deps_info_on")
load("@bazel_tools//tools/jdk:toolchain_utils.bzl", "find_java_runtime_toolchain", "find_java_toolchain")

ScalaPBAspectInfo = provider(fields = [
    "java_info",
])

def _import_paths(proto):
    source_root = proto.proto_source_root
    if "." == source_root:
        return [src.path for src in proto.direct_sources]
    else:
        offset = len(source_root) + 1  # + '/'
        return [src.path[offset:] for src in proto.direct_sources]

def _code_should_be_generated(ctx, toolchain):
    # This feels rather hacky and odd, but we can't compare the labels to ignore a target easily
    # since the @ or // forms seem to not have good equality :( , so we aim to make them absolute
    #
    # the backlisted protos in the tool chain get made into to absolute paths
    # so we make the local target we are looking at absolute too
    target_absolute_label = ctx.label
    if not str(target_absolute_label)[0] == "@":
        target_absolute_label = Label("@%s//%s:%s" % (ctx.workspace_name, ctx.label.package, ctx.label.name))

    return toolchain.blacklisted_protos.get(target_absolute_label) == None

def _compile_deps(ctx, toolchain):
    deps_toolchain_type_label = "@io_bazel_rules_scala//scala_proto:deps_toolchain_type"
    return [
        dep[JavaInfo]
        for id in toolchain.compile_dep_ids
        for dep in find_deps_info_on(ctx, deps_toolchain_type_label, id).deps
    ]

def _pack_sources(ctx, src_jars):
    return java_common.pack_sources(
        ctx.actions,
        source_jars = src_jars,
        output_source_jar = ctx.actions.declare_file(ctx.label.name + "_scalapb-src.jar"),
        java_toolchain = find_java_toolchain(ctx, ctx.attr._java_toolchain),
        host_javabase = find_java_runtime_toolchain(ctx, ctx.attr._host_javabase),
    )

def _generate_sources(ctx, toolchain, proto):
    sources = _import_paths(proto)
    descriptors = proto.transitive_descriptor_sets
    outputs = {
        k: ctx.actions.declare_file("%s_%s_scalapb.srcjar" % (ctx.label.name, k))
        for k in toolchain.generators
    }

    args = ctx.actions.args()
    args.set_param_file_format("multiline")
    args.use_param_file(param_file_arg = "@%s", use_always = True)
    for gen, out in outputs.items():
        args.add("--" + gen + "_out", out)
        args.add("--" + gen + "_opt", toolchain.opts)
    args.add_joined("--descriptor_set_in", descriptors, join_with = ctx.configuration.host_path_separator)
    args.add_all(sources)

    ctx.actions.run(
        executable = toolchain.worker,
        arguments = [toolchain.worker_flags, args],
        inputs = depset(transitive = [descriptors, toolchain.extra_generator_jars]),
        outputs = outputs.values(),
        tools = [toolchain.protoc],
        mnemonic = "ProtoScalaPBRule",
        execution_requirements = {"supports-workers": "1"},
    )

    return outputs.values()

def _compile_sources(ctx, toolchain, proto, src_jars, deps):
    output = ctx.actions.declare_file(ctx.label.name + "_scalapb.jar")
    manifest = ctx.actions.declare_file(ctx.label.name + "_MANIFEST.MF")
    write_manifest_file(ctx.actions, manifest, None)
    statsfile = ctx.actions.declare_file(ctx.label.name + "_scalac.statsfile")
    diagnosticsfile = ctx.actions.declare_file(ctx.label.name + "_scalac.diagnosticsproto")
    compile_deps = deps + _compile_deps(ctx, toolchain)
    merged_deps = java_common.merge(compile_deps)

    # this only compiles scala, not the ijar, but we don't
    # want the ijar for generated code anyway: any change
    # in the proto generally will change the interface and
    # method bodies
    compile_scala(
        ctx,
        ctx.label,
        output,
        manifest,
        statsfile,
        diagnosticsfile,
        sources = [],
        cjars = merged_deps.compile_jars,
        all_srcjars = depset(src_jars),
        transitive_compile_jars = merged_deps.transitive_compile_time_jars,
        plugins = [],
        resource_strip_prefix = "" if proto.proto_source_root == "." else proto.proto_source_root,
        resources = proto.direct_sources,
        resource_jars = [],
        labels = {},
        in_scalacopts = [],
        print_compile_time = False,
        expect_java_output = False,
        scalac_jvm_flags = [],
        scalac = toolchain.scalac,
        dependency_info = legacy_unclear_dependency_info_for_protobuf_scrooge(ctx),
        unused_dependency_checker_ignored_targets = [],
    )

    return JavaInfo(
        source_jar = _pack_sources(ctx, src_jars),
        output_jar = output,
        compile_jar = output,
        deps = compile_deps,
        exports = compile_deps,
        runtime_deps = compile_deps,
    )

####
# This is applied to the DAG of proto_librarys reachable from a deps
# or a scalapb_scala_library. Each proto_library will be one scalapb
# invocation assuming it has some sources.
def _scalapb_aspect_impl(target, ctx):
    if ProtoInfo not in target:
        # We allow some dependencies which are not protobuf, but instead
        # are jvm deps. This is to enable cases of custom generators which
        # add a needed jvm dependency.
        return [ScalaPBAspectInfo(java_info = target[JavaInfo])]

    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala_proto:toolchain_type"]
    proto = target[ProtoInfo]
    deps = [d[ScalaPBAspectInfo].java_info for d in ctx.rule.attr.deps]

    if proto.direct_sources and _code_should_be_generated(ctx, toolchain):
        src_jars = _generate_sources(ctx, toolchain, proto)
        java_info = _compile_sources(ctx, toolchain, proto, src_jars, deps)
        return [ScalaPBAspectInfo(java_info = java_info)]
    else:
        # this target is only an aggregation target
        return [ScalaPBAspectInfo(java_info = java_common.merge(deps))]

scalapb_aspect = aspect(
    implementation = _scalapb_aspect_impl,
    attr_aspects = ["deps"],
    incompatible_use_toolchain_transition = True,
    attrs = {
        "_java_toolchain": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_toolchain"),
        ),
        "_host_javabase": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
            cfg = "host",
        ),
    },
    toolchains = [
        "@io_bazel_rules_scala//scala:toolchain_type",
        "@io_bazel_rules_scala//scala_proto:toolchain_type",
        "@io_bazel_rules_scala//scala_proto:deps_toolchain_type",
    ],
)
