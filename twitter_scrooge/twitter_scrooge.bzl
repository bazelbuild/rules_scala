load("@bazel_skylib//lib:dicts.bzl", "dicts")
load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
    _default_scala_version = "default_scala_version",
)
load(
    "//scala/private:common.bzl",
    "write_manifest_file",
)
load(
    "//scala/private:dependency.bzl",
    "legacy_unclear_dependency_info_for_protobuf_scrooge",
)
load(
    "//scala/private:rule_impls.bzl",
    "compile_java",
    "compile_scala",
)
load("@io_bazel_rules_scala//thrift:thrift_info.bzl", "ThriftInfo")
load(
    "@io_bazel_rules_scala//thrift:thrift.bzl",
    "merge_thrift_infos",
)
load("//third_party/repositories:repositories.bzl", "repositories")

_jar_extension = ".jar"

def twitter_scrooge(
        scala_version = _default_scala_version(),
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {}):
    repositories(
        scala_version = scala_version,
        for_artifact_ids = [
            "libthrift",
            "io_bazel_rules_scala_scrooge_core",
            "io_bazel_rules_scala_scrooge_generator",
            "io_bazel_rules_scala_util_core",
            "io_bazel_rules_scala_util_logging",
            "io_bazel_rules_scala_mustache",  # Mustache is needed to generate java from thrift, and is passed further down.
            "io_bazel_rules_scala_guava",
            "io_bazel_rules_scala_javax_annotation_api",
        ],
        maven_servers = maven_servers,
        fetch_sources = False,
        overriden_artifacts = overriden_artifacts,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/thrift/libthrift",
        actual = "@libthrift",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/thrift/scrooge_core",
        actual = "@io_bazel_rules_scala_scrooge_core",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/thrift/mustache",
        actual = "@io_bazel_rules_scala_mustache",
    )

    # scrooge-generator needs these runtime_deps to generate java from thrift.
    if not native.existing_rule("io_bazel_rules_scala/dependency/scala/guava"):
        native.bind(
            name = "io_bazel_rules_scala/dependency/scala/guava",
            actual = "@io_bazel_rules_scala_guava",
        )

    native.bind(
        name = "io_bazel_rules_scala/dependency/thrift/scrooge_generator",
        actual = "@io_bazel_rules_scala_scrooge_generator",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/thrift/util_core",
        actual = "@io_bazel_rules_scala_util_core",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/thrift/util_logging",
        actual = "@io_bazel_rules_scala_util_logging",
    )

    # This is a shim needed to import `@javax.annotation.Generated` when compiled with jdk11.
    if not native.existing_rule("io_bazel_rules_scala/dependency/thrift/javax_annotation_api"):
        native.bind(
            name = "io_bazel_rules_scala/dependency/thrift/javax_annotation_api",
            actual = "@io_bazel_rules_scala_javax_annotation_api",
        )

def _colon_paths(data):
    return ":".join([f.path for f in sorted(data)])

ScroogeAspectInfo = provider(fields = [
    "thrift_info",
    "src_jars",
    "output_files",
    "java_info",
])

ScroogeInfo = provider(fields = [
    "aspect_info",
])

ScroogeImport = provider(fields = [
    "java_info",
    "thrift_info",
])

def merge_scrooge_aspect_info(scrooges):
    return ScroogeAspectInfo(
        src_jars = depset(transitive = [s.src_jars for s in scrooges]),
        output_files = depset(transitive = [s.output_files for s in scrooges]),
        thrift_info = merge_thrift_infos([s.thrift_info for s in scrooges]),
        java_info = java_common.merge([s.java_info for s in scrooges]),
    )

def _generate_jvm_code(ctx, label, compile_thrifts, include_thrifts, jar_output, language):
    # bazel worker arguments cannot be empty so we pad to ensure non-empty
    # and drop it off on the other side
    # https://github.com/bazelbuild/bazel/issues/3329
    worker_arg_pad = "_"
    path_content = "\n".join([
        worker_arg_pad + _colon_paths(ps)
        for ps in [compile_thrifts, include_thrifts, [], []]
    ])
    worker_content = "{output}\n{paths}\n{flags}".format(
        output = jar_output.path,
        paths = path_content,
        flags = worker_arg_pad + ":".join([
            # always add finagle option which is a no-op if there are no services
            # we could put "include_services" on thrift_info, if needed
            "--with-finagle",
            "--language={}".format(language),
        ]),
    )

    # Since we may want to generate several languages from this thrift target,
    # we need to mix the language into the worker input file.
    argfile = ctx.actions.declare_file(
        "{}_{}_worker_input".format(label.name, language),
        sibling = jar_output,
    )
    ctx.actions.write(output = argfile, content = worker_content)
    ctx.actions.run(
        executable = ctx.executable._pluck_scrooge_scala,
        inputs = compile_thrifts + include_thrifts + [argfile],
        outputs = [jar_output],
        mnemonic = "ScroogeRule",
        progress_message = "creating scrooge files %s" % ctx.label,
        execution_requirements = {"supports-workers": "1"},
        #  when we run with a worker, the `@argfile.path` is removed and passed
        #  line by line as arguments in the protobuf. In that case,
        #  the rest of the arguments are passed to the process that
        #  starts up and stays resident.

        # In either case (worker or not), they will be jvm flags which will
        # be correctly handled since the executable is a jvm app that will
        # consume the flags on startup.
        #arguments = ["--jvm_flag=%s" % flag for flag in ctx.attr.jvm_flags] +
        arguments = ["@" + argfile.path],
    )

def _compiled_jar_file(actions, scrooge_jar):
    scrooge_jar_name = scrooge_jar.basename

    # ends with .srcjar, so remove last 6 characters
    without_suffix = scrooge_jar_name[0:len(scrooge_jar_name) - 6]

    # this already ends with _scrooge because that is how scrooge_jar is named
    compiled_jar = without_suffix + "jar"
    return actions.declare_file(compiled_jar, sibling = scrooge_jar)

def _create_java_info_provider(scrooge_jar, all_deps, output):
    return JavaInfo(
        source_jar = scrooge_jar,
        deps = all_deps,
        runtime_deps = all_deps,
        exports = all_deps,
        output_jar = output,
        compile_jar = output,
    )

def _compile_generated_scala(
        ctx,
        label,
        output,
        scrooge_jar,
        deps_java_info,
        implicit_deps):
    manifest = ctx.actions.declare_file(
        label.name + "_MANIFEST.MF",
        sibling = scrooge_jar,
    )
    write_manifest_file(ctx.actions, manifest, None)
    statsfile = ctx.actions.declare_file(
        label.name + "_scalac.statsfile",
        sibling = scrooge_jar,
    )
    diagnosticsfile = ctx.actions.declare_file(
        label.name + "_scalac.diagnosticsproto",
        sibling = scrooge_jar,
    )
    all_deps = _concat_lists(deps_java_info, implicit_deps)
    merged_deps = java_common.merge(all_deps)

    # this only compiles scala, not the ijar, but we don't
    # want the ijar for generated code anyway: any change
    # in the thrift generally will change the interface and
    # method bodies
    compile_scala(
        ctx,
        label,
        output,
        manifest,
        statsfile,
        diagnosticsfile,
        sources = [],
        cjars = merged_deps.transitive_compile_time_jars,
        all_srcjars = depset([scrooge_jar]),
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
        dependency_info = legacy_unclear_dependency_info_for_protobuf_scrooge(ctx),
        unused_dependency_checker_ignored_targets = [],
    )

    return _create_java_info_provider(scrooge_jar, all_deps, output)

def _compile_generated_java(
        ctx,
        label,
        output,
        scrooge_jar,
        deps_java_info,
        implicit_deps):
    all_deps = _concat_lists(deps_java_info, implicit_deps)
    merged_deps = java_common.merge(all_deps)

    compile_java(
        ctx,
        source_jars = [scrooge_jar],
        source_files = [],
        output = output,
        extra_javac_opts = [],
        providers_of_dependencies = [merged_deps],
    )

    return _create_java_info_provider(scrooge_jar, all_deps, output)

def _concat_lists(list1, list2):
    all_providers = []
    all_providers.extend(list1)
    all_providers.extend(list2)
    return all_providers

def _gather_thriftinfo_from_deps(target, ctx):
    if ScroogeImport in target:
        target_import = target[ScroogeImport]
        target_ti = target_import.thrift_info
        deps = [target_import.java_info]
        transitive_ti = target_ti
    else:
        target_ti = target[ThriftInfo]
        deps = [d[ScroogeAspectInfo].java_info for d in ctx.rule.attr.deps]
        transitive_ti = merge_thrift_infos(
            [
                d[ScroogeAspectInfo].thrift_info
                for d in ctx.rule.attr.deps
            ] + [target_ti],
        )
    imps = [j[JavaInfo] for j in ctx.attr._implicit_compile_deps]

    return (
        target_ti,
        transitive_ti,
        deps,
        imps,
    )

def _compile_thrift_to_language(target_ti, transitive_ti, language, target, ctx):
    """Calls scrooge to compile thrift to the language specified in `language`.
    Returns the name of the compiled jar."""

    scrooge_file = ctx.actions.declare_file(
        target.label.name + "_scrooge_{}.srcjar".format(language),
    )

    # we sort so the inputs are always the same for caching
    compile_thrifts = sorted(target_ti.srcs.to_list())

    compile_thrift_map = {}
    for ct in compile_thrifts:
        compile_thrift_map[ct] = True
    include_thrifts = sorted([
        trans
        for trans in transitive_ti.transitive_srcs.to_list()
        if trans not in compile_thrift_map
    ])

    _generate_jvm_code(
        ctx,
        target.label,
        compile_thrifts,
        include_thrifts,
        scrooge_file,
        language,
    )
    return scrooge_file

def _common_scrooge_aspect_implementation(target, ctx, language, compiler_function):
    """Aspect implementation to generate code from thrift files in a language of choice, and then compile it.
    Takes in a `language` (either "java" or "scala") and a function to compile the generated sources.

    This aspect is applied to the DAG of thrift_librarys reachable from a deps or a scrooge_scala_library.
    Each thrift_library will be one scrooge invocation, assuming it has some sources.
    """
    (
        target_ti,
        transitive_ti,
        deps,
        imps,
    ) = _gather_thriftinfo_from_deps(target, ctx)
    if target_ti.srcs:
        scrooge_file = _compile_thrift_to_language(target_ti, transitive_ti, language, target, ctx)
        output = _compiled_jar_file(ctx.actions, scrooge_file)
        java_info = compiler_function(
            ctx,
            target.label,
            output,
            scrooge_file,
            deps,
            imps,
        )
        return [ScroogeAspectInfo(
            src_jars = depset([scrooge_file]),
            output_files = depset([output]),
            thrift_info = transitive_ti,
            java_info = java_info,
        )]
    else:
        # This target is an aggregation target. Aggregate the java_infos and return.
        return [
            ScroogeAspectInfo(
                src_jars = depset(),
                output_files = depset(),
                thrift_info = transitive_ti,
                java_info = java_common.merge(_concat_lists(deps, imps)),
            ),
        ]

def _scrooge_scala_aspect_impl(target, ctx):
    return _common_scrooge_aspect_implementation(target, ctx, "scala", _compile_generated_scala)

def _scrooge_java_aspect_impl(target, ctx):
    return _common_scrooge_aspect_implementation(target, ctx, "java", _compile_generated_java)

# Common attributes for both java and scala aspects, needed to generate JVM code from Thrift
common_attrs = {
    "_pluck_scrooge_scala": attr.label(
        executable = True,
        cfg = "host",
        default = Label("//src/scala/scripts:scrooge_worker"),
        allow_files = True,
    ),
    "_implicit_compile_deps": attr.label_list(
        providers = [JavaInfo],
        default = [
            Label(
                "//scala/private/toolchain_deps:scala_library_classpath",
            ),
            Label(
                "//external:io_bazel_rules_scala/dependency/thrift/libthrift",
            ),
            Label(
                "//external:io_bazel_rules_scala/dependency/thrift/scrooge_core",
            ),
            Label(
                "//external:io_bazel_rules_scala/dependency/thrift/util_core",
            ),
            Label(
                "//external:io_bazel_rules_scala/dependency/thrift/javax_annotation_api",
            ),
        ],
    ),
}

common_aspect_providers = [
    [ThriftInfo],
    [ScroogeImport],
]

scrooge_scala_aspect = aspect(
    implementation = _scrooge_scala_aspect_impl,
    attr_aspects = ["deps"],
    attrs = dicts.add(
        common_attrs,
        {
            "_scalac": attr.label(
                default = Label(
                    "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac",
                ),
            ),
        },
    ),
    required_aspect_providers = common_aspect_providers,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
)

scrooge_java_aspect = aspect(
    implementation = _scrooge_java_aspect_impl,
    attr_aspects = ["deps"],
    attrs = dicts.add(
        common_attrs,
        {
            "_java_toolchain": attr.label(default = Label("@bazel_tools//tools/jdk:current_java_toolchain")),
            "_host_javabase": attr.label(default = Label("@bazel_tools//tools/jdk:current_java_runtime"), cfg = "host"),
        },
    ),
    required_aspect_providers = common_aspect_providers,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    fragments = ["java"],
)

def _scrooge_jvm_library_impl(ctx):
    aspect_info = merge_scrooge_aspect_info(
        [dep[ScroogeAspectInfo] for dep in ctx.attr.deps],
    )
    if ctx.attr.exports:
        exports = [exp[JavaInfo] for exp in ctx.attr.exports]
        exports.append(aspect_info.java_info)
        all_java = java_common.merge(exports)
    else:
        all_java = aspect_info.java_info

    return [
        all_java,
        ScroogeInfo(aspect_info = aspect_info),
        DefaultInfo(files = aspect_info.output_files),
    ]

scrooge_scala_library = rule(
    implementation = _scrooge_jvm_library_impl,
    attrs = {
        "deps": attr.label_list(aspects = [scrooge_scala_aspect]),
        "exports": attr.label_list(providers = [JavaInfo]),
    },
    provides = [DefaultInfo, ScroogeInfo, JavaInfo],
)

scrooge_java_library = rule(
    # They can use the same implementation, since it's just an aggregator for the aspect info.
    implementation = _scrooge_jvm_library_impl,
    attrs = {
        "deps": attr.label_list(aspects = [scrooge_java_aspect]),
        "exports": attr.label_list(providers = [JavaInfo]),
    },
    provides = [DefaultInfo, ScroogeInfo, JavaInfo],
)

def _scrooge_scala_import_impl(ctx):
    jars_jis = [
        JavaInfo(
            output_jar = scala_jar,
            compile_jar = scala_jar,
        )
        for scala_jar in ctx.files.scala_jars
    ]
    java_info = java_common.merge(
        [imp[JavaInfo] for imp in ctx.attr._implicit_compile_deps] + jars_jis,
    )

    # to make the thrift_info, we only put this in the
    # transitive part
    ti = ThriftInfo(
        srcs = depset(),
        transitive_srcs = depset(ctx.files.thrift_jars),
    )
    return [java_info, ti, ScroogeImport(java_info = java_info, thrift_info = ti)]

# Allows you to consume thrifts and compiled jars from external repos
scrooge_scala_import = rule(
    implementation = _scrooge_scala_import_impl,
    attrs = {
        "thrift_jars": attr.label_list(allow_files = [".jar"]),
        "scala_jars": attr.label_list(allow_files = [".jar"]),
        "_implicit_compile_deps": attr.label_list(
            providers = [JavaInfo],
            default = [
                Label(
                    "//scala/private/toolchain_deps:scala_library_classpath",
                ),
                Label(
                    "//external:io_bazel_rules_scala/dependency/thrift/libthrift",
                ),
                Label(
                    "//external:io_bazel_rules_scala/dependency/thrift/scrooge_core",
                ),
            ],
        ),
    },
    provides = [ThriftInfo, JavaInfo, ScroogeImport],
)
