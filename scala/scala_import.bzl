load("//scala/private:rule_impls.bzl", "specified_java_compile_toolchain")
load("//scala/settings:stamp_settings.bzl", "StampScalaImport")
load("//scala:jars_to_labels.bzl", "JarsToLabelsInfo")

def _stamp_jar(ctx, jar):
    stamped_jar_filename = "%s.stamp/%s" % (ctx.label.name, jar.basename)
    symlink_file = ctx.actions.declare_file(stamped_jar_filename)
    ctx.actions.symlink(output = symlink_file, target_file = jar)
    return java_common.stamp_jar(
        actions = ctx.actions,
        jar = symlink_file,
        target_label = ctx.label,
        java_toolchain = specified_java_compile_toolchain(ctx),
    )

# intellij part is tested manually, tread lightly when changing there
# if you change make sure to manually re-import an intellij project and see imports
# are resolved (not red) and clickable
def _scala_import_impl(ctx):
    target_data = _code_jars_and_intellij_metadata_from(
        ctx.attr.jars,
        ctx.file.srcjar,
    )

    compile_jars = target_data.code_jars
    intellij_metadata = target_data.intellij_metadata

    stamping_enabled = ctx.attr.stamp[StampScalaImport].enabled

    maybe_stamped_jars = [
        _stamp_jar(ctx, jar)
        for jar in compile_jars
    ] if stamping_enabled else compile_jars

    compile_jars_depset = depset(compile_jars)

    exports = java_common.merge([export[JavaInfo] for export in ctx.attr.exports])

    jars2labels = {}
    _collect_labels(ctx.attr.deps, jars2labels)
    _collect_labels(ctx.attr.exports, jars2labels)  #untested
    _add_labels_of_current_code_jars(
        depset(transitive = [compile_jars_depset, exports.compile_jars]),
        ctx.label,
        jars2labels,
    )  #last to override the label of the export compile jars to the current target

    if compile_jars:
        current_target_providers = [
            _new_java_info(ctx, compile_jars[index], maybe_stamped_jars[index])
            for index in range(len(compile_jars))
        ]
    else:
        # TODO(#8867): Migrate away from the placeholder jar hack when #8867 is fixed.
        current_target_providers = [_new_java_info(ctx, ctx.file._placeholder_jar, ctx.file._placeholder_jar)]

    merged_providers = java_common.merge(current_target_providers)
    return [
        merged_providers,
        DefaultInfo(
            files = compile_jars_depset,
        ),
        JarsToLabelsInfo(jars_to_labels = jars2labels),
        OutputGroupInfo(_source_jars = merged_providers.source_jars),
    ]

def _new_java_info(ctx, jar, stamped_jar):
    return JavaInfo(
        output_jar = jar,
        compile_jar = stamped_jar,
        exports = [target[JavaInfo] for target in ctx.attr.exports],
        deps = [target[JavaInfo] for target in ctx.attr.deps],
        runtime_deps = [target[JavaInfo] for target in ctx.attr.runtime_deps],
        source_jar = ctx.file.srcjar,
        neverlink = ctx.attr.neverlink,
    )

def _add_labels_of_current_code_jars(code_jars, label, jars2labels):
    for jar in code_jars.to_list():
        jars2labels[jar.path] = label

def _code_jars_and_intellij_metadata_from(jars, srcjar):
    code_jars = []
    intellij_metadata = []
    for jar in jars:
        current_jar_code_jars = _filter_out_non_code_jars(jar.files)
        current_jar_source_jars = _source_jars(jar, srcjar)
        code_jars += current_jar_code_jars
        for current_class_jar in current_jar_code_jars:  #intellij, untested
            intellij_metadata.append(
                struct(
                    ijar = None,
                    class_jar = current_class_jar,
                    source_jars = current_jar_source_jars,
                ),
            )
    return struct(code_jars = code_jars, intellij_metadata = intellij_metadata)

def _source_jars(jar, srcjar):
    if srcjar:
        return [srcjar]
    else:
        jar_source_jars = [
            file
            for file in jar.files.to_list()
            if _is_source_jar(file)
        ]
        return jar_source_jars

def _filter_out_non_code_jars(files):
    return [file for file in files.to_list() if not _is_source_jar(file)]

def _is_source_jar(file):
    return file.basename.endswith("-sources.jar")

def _collect_labels(deps, jars2labels):
    for dep_target in deps:
        if JarsToLabelsInfo in dep_target:
            jars2labels.update(dep_target[JarsToLabelsInfo].jars_to_labels)

        #scala_library doesn't add labels to the direct dependency itself
        java_provider = dep_target[JavaInfo]
        for jar in java_provider.compile_jars.to_list():
            jars2labels[jar.path] = dep_target.label

scala_import = rule(
    implementation = _scala_import_impl,
    attrs = {
        "jars": attr.label_list(
            allow_files = True,
        ),  #current hidden assumption is that these point to full, not ijar'd jars
        "deps": attr.label_list(),
        "runtime_deps": attr.label_list(),
        "exports": attr.label_list(),
        "neverlink": attr.bool(),
        "srcjar": attr.label(allow_single_file = True),
        "_placeholder_jar": attr.label(
            allow_single_file = True,
            default = Label(
                "//scala:libPlaceHolderClassToCreateEmptyJarForScalaImport.jar",
            ),
        ),
        "stamp": attr.label(
            doc = "Adds Target-Label attribute to MANIFEST.MF for dep tracking",
            default = Label("//scala/settings:stamp_scala_import"),
        ),
        "java_compile_toolchain": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_toolchain"),
        ),
    },
    toolchains = ["@bazel_tools//tools/jdk:toolchain_type"],
    provides = [JavaInfo],
)
