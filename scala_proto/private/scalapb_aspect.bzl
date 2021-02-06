load("@rules_proto//proto:defs.bzl", "ProtoInfo")
load("//scala/private:common.bzl", "write_manifest_file")
load("//scala/private:dependency.bzl", "legacy_unclear_dependency_info_for_protobuf_scrooge")
load("//scala/private:rule_impls.bzl", "compile_scala")
load("//scala_proto/private:proto_to_scala_src.bzl", "proto_to_scala_src")
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "find_deps_info_on")

ScalaPBAspectInfo = provider(fields = [
    "java_info",
])

def _direct_sources(proto):
    source_root = proto.proto_source_root
    if "." == source_root:
        return [src.path for src in proto.direct_sources]
    else:
        offset = len(source_root) + 1  # + '/'
        return [src.path[offset:] for src in proto.direct_sources]

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

def _compiled_jar_file(actions, scalapb_jar):
    scalapb_jar_name = scalapb_jar.basename

    # ends with .srcjar, so remove last 6 characters
    without_suffix = scalapb_jar_name[0:len(scalapb_jar_name) - 6]

    # this already ends with _scalapb because that is how scalapb_jar is named
    compiled_jar = without_suffix + "jar"
    return actions.declare_file(compiled_jar, sibling = scalapb_jar)

def _compile_scala(
        ctx,
        scalac,
        label,
        output,
        src_jars,
        deps_java_info,
        implicit_deps,
        resources,
        resource_strip_prefix):
    manifest = ctx.actions.declare_file(label.name + "_MANIFEST.MF")
    write_manifest_file(ctx.actions, manifest, None)
    statsfile = ctx.actions.declare_file(label.name + "_scalac.statsfile")
    diagnosticsfile = ctx.actions.declare_file(label.name + "_scalac.diagnosticsproto")
    merged_deps = java_common.merge(_concat_lists(deps_java_info, implicit_deps))

    # this only compiles scala, not the ijar, but we don't
    # want the ijar for generated code anyway: any change
    # in the proto generally will change the interface and
    # method bodies
    compile_scala(
        ctx,
        label,
        output,
        manifest,
        statsfile,
        diagnosticsfile,
        sources = [],
        cjars = merged_deps.compile_jars,
        all_srcjars = src_jars,
        transitive_compile_jars = merged_deps.transitive_compile_time_jars,
        plugins = [],
        resource_strip_prefix = resource_strip_prefix,
        resources = resources,
        resource_jars = [],
        labels = {},
        in_scalacopts = [],
        print_compile_time = False,
        expect_java_output = False,
        scalac_jvm_flags = [],
        scalac = scalac,
        dependency_info = legacy_unclear_dependency_info_for_protobuf_scrooge(ctx),
        unused_dependency_checker_ignored_targets = [],
    )

    return JavaInfo(
#        source_jar = None,
        deps = deps_java_info + implicit_deps,
        runtime_deps = deps_java_info + implicit_deps,
        exports = deps_java_info + implicit_deps,
        output_jar = output,
        compile_jar = output,
    )

def code_should_be_generated(target, ctx):
    # This feels rather hacky and odd, but we can't compare the labels to ignore a target easily
    # since the @ or // forms seem to not have good equality :( , so we aim to make them absolute
    #
    # the backlisted protos in the tool chain get made into to absolute paths
    # so we make the local target we are looking at absolute too
    target_absolute_label = target.label
    if not str(target_absolute_label)[0] == "@":
        target_absolute_label = Label("@%s//%s:%s" % (ctx.workspace_name, target.label.package, target.label.name))

    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala_proto:toolchain_type"]

    for lbl in toolchain.blacklisted_protos:
        if (lbl.label == target_absolute_label):
            return False

    return True

def _compile_deps(ctx):
    deps_toolchain_type_label = "@io_bazel_rules_scala//scala_proto:deps_toolchain_type"

    compile_deps = find_deps_info_on(
        ctx,
        deps_toolchain_type_label,
        "scalapb_compile_deps",
    ).deps

    imps = [dep[JavaInfo] for dep in compile_deps]

    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala_proto:toolchain_type"]

    if toolchain.with_grpc:
        grpc_deps = find_deps_info_on(ctx, deps_toolchain_type_label, "scalapb_grpc_deps").deps
        imps.extend([dep[JavaInfo] for dep in grpc_deps])

    return imps

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
        return [ScalaPBAspectInfo(java_info = target[JavaInfo])]
    else:
        proto = target[ProtoInfo]
        if proto.direct_sources and code_should_be_generated(target, ctx):
            toolchain = ctx.toolchains["@io_bazel_rules_scala//scala_proto:toolchain_type"]
            direct_sources = _direct_sources(proto)
            descriptors = proto.transitive_descriptor_sets
            outputs = {
                k: ctx.actions.declare_file("%s_%s_scalapb.srcjar" % (target.label.name, k))
                for k in toolchain.generators.keys()
            }
            opt = ",".join(toolchain.opts)

            args = ctx.actions.args()
            args.set_param_file_format("multiline")
            args.use_param_file(param_file_arg = "@%s", use_always = True)
            for gen, out in outputs.items():
                args.add("--" + gen + "_out", out)
                args.add("--" + gen + "_opt", opt)
            args.add_joined("--descriptor_set_in", descriptors, join_with = ctx.configuration.host_path_separator)
            args.add_all(direct_sources)

            ctx.actions.run(
                executable = toolchain.worker,
                arguments = [args],
                inputs = depset(transitive = [descriptors, toolchain.extra_generator_jars]),
                outputs = outputs.values(),
                tools = [toolchain.protoc],
                env = toolchain.env,
                mnemonic = "ProtoScalaPBRule",
                execution_requirements = {"supports-workers": "1"},
            )

            src_jars = depset(outputs.values())
            output = ctx.actions.declare_file(target.label.name + "_scalapb.jar")
            outs = depset([output])
            compile_deps = _compile_deps(ctx)
            java_info = _compile_scala(
                ctx,
                toolchain.scalac,
                target.label,
                output,
                src_jars,
                deps,
                compile_deps,
                proto.direct_sources,
                "" if proto.proto_source_root == "." else proto.proto_source_root,
            )
            return [ScalaPBAspectInfo(java_info = java_info)]
        else:
            # this target is only an aggregation target
            return [ScalaPBAspectInfo(java_info = java_common.merge(deps))]

def _concat_lists(list1, list2):
    all_providers = []
    all_providers.extend(list1)
    all_providers.extend(list2)
    return all_providers

scalapb_aspect = aspect(
    implementation = _scalapb_aspect_impl,
    attr_aspects = ["deps"],
    incompatible_use_toolchain_transition = True,
    toolchains = [
        "@io_bazel_rules_scala//scala:toolchain_type",
        "@io_bazel_rules_scala//scala_proto:toolchain_type",
        "@io_bazel_rules_scala//scala_proto:deps_toolchain_type",
    ],
)
