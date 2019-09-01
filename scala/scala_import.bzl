load("@io_bazel_rules_scala//scala:jars_to_labels.bzl", "JarsToLabelsInfo")

#intellij part is tested manually, tread lightly when changing there
#if you change make sure to manually re-import an intellij project and see imports
#are resolved (not red) and clickable
def _scala_import_impl(ctx):
    target_data = _code_jars_and_intellij_metadata_from(
        ctx.attr.jars,
        ctx.file.srcjar,
    )
    (
        current_target_compile_jars,
        intellij_metadata,
    ) = (target_data.code_jars, target_data.intellij_metadata)
    current_jars = depset(current_target_compile_jars)
    exports = java_common.merge([export[JavaInfo] for export in ctx.attr.exports])
    transitive_runtime_jars = \
        java_common.merge([dep[JavaInfo] for dep in ctx.attr.runtime_deps]) \
            .transitive_runtime_jars
    jars2labels = {}
    _collect_labels(ctx.attr.deps, jars2labels)
    _collect_labels(ctx.attr.exports, jars2labels)  #untested
    _add_labels_of_current_code_jars(
        depset(transitive = [current_jars, exports.compile_jars]),
        ctx.label,
        jars2labels,
    )  #last to override the label of the export compile jars to the current target

    if current_target_compile_jars:
        current_target_providers = [_new_java_info(ctx, jar) for jar in current_target_compile_jars]
    else:
        # TODO(#8867): Migrate away from the placeholder jar hack when #8867 is fixed.
        current_target_providers = [_new_java_info(ctx, ctx.file._placeholder_jar)]

    return struct(
        scala = struct(
            outputs = struct(jars = intellij_metadata),
        ),
        providers = [
            java_common.merge(current_target_providers),
            DefaultInfo(
                files = current_jars,
            ),
            JarsToLabelsInfo(jars_to_labels = jars2labels),
        ],
    )

def _new_java_info(ctx, jar):
    return JavaInfo(
        output_jar = jar,
        compile_jar = jar,
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
            default = Label("@io_bazel_rules_scala//scala:libPlaceHolderClassToCreateEmptyJarForScalaImport.jar"),
        ),
    },
)
