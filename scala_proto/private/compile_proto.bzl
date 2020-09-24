load("//scala/private:rule_impls.bzl", "compile_scala")
load("//scala/private:common.bzl", "write_manifest_file")
load("//scala/private:dependency.bzl", "legacy_unclear_dependency_info_for_protobuf_scrooge")

def _concat_lists(list1, list2):
    all_providers = []
    all_providers.extend(list1)
    all_providers.extend(list2)
    return all_providers

def compiled_jar_file(actions, scalapb_jar):
    scalapb_jar_name = scalapb_jar.basename

    # ends with .srcjar, so remove last 6 characters
    without_suffix = scalapb_jar_name[0:len(scalapb_jar_name) - 6]

    # this already ends with _scalapb because that is how scalapb_jar is named
    compiled_jar = without_suffix + "jar"
    return actions.declare_file(compiled_jar, sibling = scalapb_jar)

def compile_proto(
        ctx,
        scalac,
        label,
        output,
        scalapb_jar,
        deps_java_info,
        implicit_deps,
        resources,
        resource_strip_prefix):
    manifest = ctx.actions.declare_file(
        label.name + "_MANIFEST.MF",
        sibling = scalapb_jar,
    )
    write_manifest_file(ctx.actions, manifest, None)
    statsfile = ctx.actions.declare_file(
        label.name + "_scalac.statsfile",
        sibling = scalapb_jar,
    )
    diagnosticsfile = ctx.actions.declare_file(
        label.name + "_scalac.diagnosticsproto",
        sibling = scalapb_jar,
    )
    merged_deps = java_common.merge(_concat_lists(deps_java_info, implicit_deps))

    # this only compiles scala, not the ijar, but we don't
    # want the ijar for generated code anyway: any change
    # in the proto generally will change the interface and
    # method bodies
    compile_scala(
        ctx,
        Label("%s-fast" % (label)),
        output,
        manifest,
        statsfile,
        diagnosticsfile,
        sources = [],
        cjars = merged_deps.compile_jars,
        all_srcjars = depset([scalapb_jar]),
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
        source_jar = scalapb_jar,
        deps = deps_java_info + implicit_deps,
        runtime_deps = deps_java_info + implicit_deps,
        exports = deps_java_info + implicit_deps,
        output_jar = output,
        compile_jar = output,
    )