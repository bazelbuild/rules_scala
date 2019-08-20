load("@io_bazel_rules_scala//scala:providers.bzl", "create_scala_provider")
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    "collect_jars",
    "collect_srcjars",
    "sanitize_string_for_usage",
    "write_manifest",
)
load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "common_attrs_for_plugin_bootstrapping",
    "implicit_deps",
    "resolve_deps",
)
load("@io_bazel_rules_scala//scala/private:common_outputs.bzl", "common_outputs")
load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "build_deployable",
    "collect_jars_from_common_ctx",
    "compile_or_empty",
    "get_scalac_provider",
    "get_unused_dependency_checker_mode",
    "pack_source_jars",
)

##
# Common stuff to _library rules
##

_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(
        allow_files = False,
        aspects = [_coverage_replacements_provider.aspect],
    ),
}

def _lib(
        ctx,
        base_classpath,
        non_macro_lib,
        unused_dependency_checker_mode,
        unused_dependency_checker_ignored_targets):
    # Build up information from dependency-like attributes

    # This will be used to pick up srcjars from non-scala library
    # targets (like thrift code generation)
    srcjars = collect_srcjars(ctx.attr.deps)

    unused_dependency_checker_is_off = unused_dependency_checker_mode == "off"
    jars = collect_jars_from_common_ctx(
        ctx,
        base_classpath,
        unused_dependency_checker_is_off = unused_dependency_checker_is_off,
    )

    (cjars, transitive_rjars) = (jars.compile_jars, jars.transitive_runtime_jars)

    write_manifest(ctx)
    outputs = compile_or_empty(
        ctx,
        ctx.outputs.manifest,
        cjars,
        srcjars,
        non_macro_lib,
        jars.transitive_compile_jars,
        jars.jars2labels.jars_to_labels,
        [],
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in base_classpath + ctx.attr.exports +
                          unused_dependency_checker_ignored_targets
        ],
        unused_dependency_checker_mode = unused_dependency_checker_mode,
        deps_providers = jars.deps_providers,
    )

    transitive_rjars = depset(outputs.full_jars, transitive = [transitive_rjars])

    build_deployable(ctx, transitive_rjars.to_list())

    # Using transitive_files since transitive_rjars a depset and avoiding linearization
    runfiles = ctx.runfiles(
        transitive_files = transitive_rjars,
        collect_data = True,
    )

    # Add information from exports (is key that AFTER all build actions/runfiles analysis)
    # Since after, will not show up in deploy_jar or old jars runfiles
    # Notice that compile_jars is intentionally transitive for exports
    exports_jars = collect_jars(ctx.attr.exports)
    transitive_rjars = depset(
        transitive = [transitive_rjars, exports_jars.transitive_runtime_jars],
    )

    source_jars = pack_source_jars(ctx) + outputs.source_jars

    scalaattr = create_scala_provider(
        class_jar = outputs.class_jar,
        compile_jars = depset(
            outputs.ijars,
            transitive = [exports_jars.compile_jars],
        ),
        deploy_jar = ctx.outputs.deploy_jar,
        full_jars = outputs.full_jars,
        ijar = outputs.ijar,
        source_jars = source_jars,
        statsfile = ctx.outputs.statsfile,
        transitive_runtime_jars = transitive_rjars,
    )

    return struct(
        files = depset([ctx.outputs.jar] + outputs.full_jars),  # Here is the default output
        instrumented_files = outputs.coverage.instrumented_files,
        jars_to_labels = jars.jars2labels,
        providers = [outputs.merged_provider, jars.jars2labels] + outputs.coverage.providers,
        runfiles = runfiles,
        scala = scalaattr,
    )

##
# scala_library
##

def _scala_library_impl(ctx):
    if ctx.attr.jvm_flags:
        print("'jvm_flags' for scala_library is deprecated. It does nothing today and will be removed from scala_library to avoid confusion.")
    scalac_provider = get_scalac_provider(ctx)
    unused_dependency_checker_mode = get_unused_dependency_checker_mode(ctx)
    return _lib(
        ctx,
        scalac_provider.default_classpath,
        True,
        unused_dependency_checker_mode,
        ctx.attr.unused_dependency_checker_ignored_targets,
    )

_scala_library_attrs = {}

_scala_library_attrs.update(implicit_deps)

_scala_library_attrs.update(common_attrs)

_scala_library_attrs.update(_library_attrs)

_scala_library_attrs.update(resolve_deps)

scala_library = rule(
    attrs = _scala_library_attrs,
    fragments = ["java"],
    outputs = common_outputs,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_library_impl,
)

# Scala library suite generates a series of scala libraries
# then it depends on them with a meta one which exports all the sub targets
def scala_library_suite(
        name,
        srcs = [],
        exports = [],
        visibility = None,
        **kwargs):
    ts = []
    for src_file in srcs:
        n = "%s_lib_%s" % (name, sanitize_string_for_usage(src_file))
        scala_library(
            name = n,
            srcs = [src_file],
            visibility = visibility,
            exports = exports,
            unused_dependency_checker_mode = "off",
            **kwargs
        )
        ts.append(n)
    scala_library(
        name = name,
        visibility = visibility,
        exports = exports + ts,
        deps = ts,
    )

##
# scala_library_for_plugin_bootstrapping
##

def _scala_library_for_plugin_bootstrapping_impl(ctx):
    scalac_provider = get_scalac_provider(ctx)
    return _lib(
        ctx,
        scalac_provider.default_classpath,
        True,
        unused_dependency_checker_ignored_targets = [],
        unused_dependency_checker_mode = "off",
    )

# the scala compiler plugin used for dependency analysis is compiled using `scala_library`.
# in order to avoid cyclic dependencies `scala_library_for_plugin_bootstrapping` was created for this purpose,
# which does not contain plugin related attributes, and thus avoids the cyclic dependency issue
_scala_library_for_plugin_bootstrapping_attrs = {}

_scala_library_for_plugin_bootstrapping_attrs.update(implicit_deps)

_scala_library_for_plugin_bootstrapping_attrs.update(_library_attrs)

_scala_library_for_plugin_bootstrapping_attrs.update(resolve_deps)

_scala_library_for_plugin_bootstrapping_attrs.update(
    common_attrs_for_plugin_bootstrapping,
)

scala_library_for_plugin_bootstrapping = rule(
    attrs = _scala_library_for_plugin_bootstrapping_attrs,
    fragments = ["java"],
    outputs = common_outputs,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_library_for_plugin_bootstrapping_impl,
)

##
# scala_macro_library
##

def _scala_macro_library_impl(ctx):
    scalac_provider = get_scalac_provider(ctx)
    unused_dependency_checker_mode = get_unused_dependency_checker_mode(ctx)
    return _lib(
        ctx,
        scalac_provider.default_macro_classpath,
        False,  # don't build the ijar for macros
        unused_dependency_checker_mode,
        ctx.attr.unused_dependency_checker_ignored_targets,
    )

_scala_macro_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(allow_files = False),
}

_scala_macro_library_attrs.update(implicit_deps)

_scala_macro_library_attrs.update(common_attrs)

_scala_macro_library_attrs.update(_library_attrs)

_scala_macro_library_attrs.update(resolve_deps)

# Set unused_dependency_checker_mode default to off for scala_macro_library
_scala_macro_library_attrs["unused_dependency_checker_mode"] = attr.string(
    default = "off",
    values = [
        "warn",
        "error",
        "off",
        "",
    ],
    mandatory = False,
)

scala_macro_library = rule(
    attrs = _scala_macro_library_attrs,
    fragments = ["java"],
    outputs = common_outputs,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_macro_library_impl,
)
