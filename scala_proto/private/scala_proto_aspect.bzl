load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load("//scala/private:common.bzl", "write_manifest_file")
load("//scala/private:dependency.bzl", "legacy_unclear_dependency_info_for_protobuf_scrooge")
load("//scala/private:phases/api.bzl", "extras_phases", "run_aspect_phases")
load(
    "//scala/private:rule_impls.bzl",
    "compile_scala",
    "specified_java_compile_toolchain",
)
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "find_deps_info_on")
load(
    "//scala_proto/private:scala_proto_aspect_provider.bzl",
    "ScalaProtoAspectInfo",
)

def _import_paths(proto, ctx):
    # Under Bazel 7.x, direct_sources from generated protos may still contain
    # ctx.bin_dir.path, even when proto_source_root does not. proto_source_root
    # may also be relative to ctx.bin_dir.path, or it may contain it. So we try
    # removing ctx.bin_dir.path from everything.
    bin_dir = ctx.bin_dir.path + "/"
    source_root = proto.proto_source_root
    source_root += "/" if source_root != "." else ""
    source_root = source_root.removeprefix(bin_dir)

    return [
        ds.path.removeprefix(bin_dir).removeprefix(source_root)
        for ds in proto.direct_sources
    ]

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
    deps_toolchain_type_label = Label("//scala_proto:deps_toolchain_type")
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
        java_toolchain = specified_java_compile_toolchain(ctx),
    )

def _generate_sources(ctx, toolchain, proto):
    sources = _import_paths(proto, ctx)
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
        args.add("--" + gen + "_opt", toolchain.generators_opts)
    args.add_joined("--descriptor_set_in", descriptors, join_with = ctx.configuration.host_path_separator)
    args.add_all(sources)

    ctx.actions.run(
        executable = toolchain.worker,
        arguments = [toolchain.worker_flags, args],
        inputs = depset(transitive = [descriptors, toolchain.generators_jars]),
        outputs = outputs.values(),
        tools = [toolchain.protoc],
        mnemonic = "ProtoScalaPBRule",
        execution_requirements = {"supports-workers": "1"},
    )

    return outputs.values()

def _compile_sources(ctx, toolchain, proto, src_jars, deps, scalacopts, stamp_label):
    output = ctx.actions.declare_file(ctx.label.name + "_scalapb.jar")
    manifest = ctx.actions.declare_file(ctx.label.name + "_MANIFEST.MF")
    write_manifest_file(ctx.actions, manifest, None)
    statsfile = ctx.actions.declare_file(ctx.label.name + "_scalac.statsfile")
    diagnosticsfile = ctx.actions.declare_file(ctx.label.name + "_scalac.diagnosticsproto")
    scaladepsfile = ctx.actions.declare_file(ctx.label.name + ".sdeps")
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
        scaladepsfile,
        sources = [],
        cjars = merged_deps.compile_jars,
        all_srcjars = depset(src_jars),
        transitive_compile_jars = merged_deps.transitive_compile_time_jars,
        plugins = [],
        resource_strip_prefix = "" if proto.proto_source_root == "." else proto.proto_source_root,
        resources = proto.direct_sources,
        resource_jars = [],
        labels = {},
        print_compile_time = False,
        expect_java_output = False,
        scalac_jvm_flags = [],
        scalacopts = scalacopts,
        scalac = toolchain.scalac,
        dependency_info = legacy_unclear_dependency_info_for_protobuf_scrooge(ctx),
        unused_dependency_checker_ignored_targets = [],
        stamp_target_label = stamp_label,
        additional_outputs = [],
    )

    return JavaInfo(
        source_jar = _pack_sources(ctx, src_jars),
        output_jar = output,
        compile_jar = output,
        deps = compile_deps,
        exports = compile_deps,
        runtime_deps = compile_deps,
    )

def _phase_proto_provider(ctx, p):
    return p.target[ProtoInfo]

def _phase_deps(ctx, p):
    return [d[ScalaProtoAspectInfo].java_info for d in ctx.rule.attr.deps]

def _phase_scalacopts(ctx, p):
    return ctx.toolchains[Label("//scala:toolchain_type")].scalacopts

def _phase_generate_and_compile(ctx, p):
    proto = p.proto_info
    deps = p.deps
    scalacopts = p.scalacopts
    stamp_label = p.stamp_label
    toolchain = ctx.toolchains[Label("//scala_proto:toolchain_type")]

    if proto.direct_sources and _code_should_be_generated(ctx, toolchain):
        src_jars = _generate_sources(ctx, toolchain, proto)
        java_info = _compile_sources(ctx, toolchain, proto, src_jars, deps, scalacopts, stamp_label)
        return java_info
    else:
        # this target is only an aggregation target
        return java_common.merge(deps)

def _phase_aspect_provider(ctx, p):
    return struct(
        external_providers = {
            "ScalaProtoAspectInfo": ScalaProtoAspectInfo(java_info = p.generate_and_compile),
        },
    )

def _strip_suffix(str, suffix):
    if str.endswith(suffix):
        return str[:-len(suffix)]
    else:
        return str

def _phase_stamp_label(ctx, p):
    rule_label = str(p.target.label)
    toolchain = ctx.toolchains[Label("//scala_proto:toolchain_type")]

    if toolchain.stamp_by_convention and rule_label.endswith("_proto"):
        return _strip_suffix(rule_label, "_proto") + "_scala_proto"
    else:
        return rule_label

####
# This is applied to the DAG of proto_librarys reachable from a deps
# or a scalapb_scala_library. Each proto_library will be one scalapb
# invocation assuming it has some sources.
def _scala_proto_aspect_impl(target, ctx):
    return run_aspect_phases(
        ctx,
        [
            ("proto_info", _phase_proto_provider),
            ("deps", _phase_deps),
            ("stamp_label", _phase_stamp_label),
            ("scalacopts", _phase_scalacopts),
            ("generate_and_compile", _phase_generate_and_compile),
            ("aspect_provider", _phase_aspect_provider),
        ],
        target = target,
    )

def make_scala_proto_aspect(*extras):
    attrs = {
        "_java_toolchain": attr.label(
            default = Label("@rules_java//toolchains:current_java_toolchain"),
        ),
        "_java_host_runtime": attr.label(
            default = Label(
                "@rules_java//toolchains:current_host_java_runtime",
            ),
        ),
    }
    return aspect(
        implementation = _scala_proto_aspect_impl,
        attr_aspects = ["deps"],
        provides = [ScalaProtoAspectInfo],
        attrs = dicts.add(
            attrs,
            extras_phases(extras),
            *[extra["attrs"] for extra in extras if "attrs" in extra]
        ),
        toolchains = [
            Label("//scala:toolchain_type"),
            Label("//scala_proto:toolchain_type"),
            Label("//scala_proto:deps_toolchain_type"),
            "@bazel_tools//tools/jdk:toolchain_type",
        ],
    )

scala_proto_aspect = make_scala_proto_aspect()
