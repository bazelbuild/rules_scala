load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:providers.bzl", "declare_deps_provider")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION", "SCALA_VERSIONS")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "sanitize_version", "version_suffix")

_SCALA_COMPILE_CLASSPATH_DEPS = {
    "2": [
        "@io_bazel_rules_scala_scala_compiler",
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
    ],
    "3": [
        "@io_bazel_rules_scala_scala_compiler",
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_interfaces",
        "@io_bazel_rules_scala_scala_tasty_core",
        "@io_bazel_rules_scala_scala_asm",
        "@io_bazel_rules_scala_scala_library_2",
    ],
}

_SCALA_LIBRARY_CLASSPATH_DEPS = {
    "2": [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
    ],
    "3": [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_library_2",
    ],
}

_SCALA_MACRO_CLASSPATH_DEPS = {
    "2": [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
    ],
    "3": [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_library_2",
    ],
}

_PARSER_COMBINATORS_DEPS = {
    "2": ["@io_bazel_rules_scala_scala_parser_combinators"],
    "3": ["@io_bazel_rules_scala_scala_parser_combinators"],
}

_SCALA_XML_DEPS = {
    "2": ["@io_bazel_rules_scala_scala_xml"],
    "3": ["@io_bazel_rules_scala_scala_xml"],
}

_SCALA_SEMANTICDB_DEPS = {
    "2": ["@org_scalameta_semanticdb_scalac"],
    "3": [],
}

def _dependencies_by_version(version, deps):
    return [dep + version_suffix(version) for dep in deps[version[0:1]]]

def _parser_combinators_deps(version = SCALA_VERSION):
    return _dependencies_by_version(version, _PARSER_COMBINATORS_DEPS)

def _scala_compile_classpath_deps(version = SCALA_VERSION):
    return _dependencies_by_version(version, _SCALA_COMPILE_CLASSPATH_DEPS)

def _scala_library_classpath_deps(version = SCALA_VERSION):
    return _dependencies_by_version(version, _SCALA_LIBRARY_CLASSPATH_DEPS)

def _scala_macro_classpath_deps(version = SCALA_VERSION):
    return _dependencies_by_version(version, _SCALA_MACRO_CLASSPATH_DEPS)

def _scala_xml_deps(version = SCALA_VERSION):
    return _dependencies_by_version(version, _SCALA_XML_DEPS)

def _scala_semanticdb_deps(version = SCALA_VERSION):
    return _dependencies_by_version(version, _SCALA_SEMANTICDB_DEPS)

def setup_scala_toolchain(
        name,
        scala_compile_classpath,
        scala_library_classpath,
        scala_macro_classpath,
        scala_version = SCALA_VERSION,
        scala_xml_deps = None,
        parser_combinators_deps = None,
        semanticdb_deps = None,
        enable_semanticdb = False,
        visibility = ["//visibility:public"],
        **kwargs):
    scala_xml_provider = "%s_scala_xml_provider" % name
    parser_combinators_provider = "%s_parser_combinators_provider" % name
    scala_compile_classpath_provider = "%s_scala_compile_classpath_provider" % name
    scala_library_classpath_provider = "%s_scala_library_classpath_provider" % name
    scala_macro_classpath_provider = "%s_scala_macro_classpath_provider" % name
    semanticdb_deps_provider = "%s_semanticdb_deps_provider" % name

    declare_deps_provider(
        name = scala_compile_classpath_provider,
        deps_id = "scala_compile_classpath",
        visibility = visibility,
        deps = scala_compile_classpath,
    )

    declare_deps_provider(
        name = scala_library_classpath_provider,
        deps_id = "scala_library_classpath",
        visibility = visibility,
        deps = scala_library_classpath,
    )

    declare_deps_provider(
        name = scala_macro_classpath_provider,
        deps_id = "scala_macro_classpath",
        visibility = visibility,
        deps = scala_macro_classpath,
    )

    if scala_xml_deps != None:
        declare_deps_provider(
            name = scala_xml_provider,
            deps_id = "scala_xml",
            visibility = visibility,
            deps = scala_xml_deps,
        )
    else:
        scala_xml_provider = "@io_bazel_rules_scala//scala:scala_xml_provider"

    if parser_combinators_deps != None:
        declare_deps_provider(
            name = parser_combinators_provider,
            deps_id = "parser_combinators",
            visibility = visibility,
            deps = parser_combinators_deps,
        )
    else:
        parser_combinators_provider = "@io_bazel_rules_scala//scala:parser_combinators_provider"

    dep_providers = [
        scala_xml_provider,
        parser_combinators_provider,
        scala_compile_classpath_provider,
        scala_library_classpath_provider,
        scala_macro_classpath_provider,
    ]

    if enable_semanticdb == True:
        if semanticdb_deps != None:
            declare_deps_provider(
                name = semanticdb_deps_provider,
                deps_id = "semanticdb",
                deps = [semanticdb_deps],
                visibility = visibility,
            )

            dep_providers.append(semanticdb_deps_provider)
        else:
            dep_providers.append("@io_bazel_rules_scala//scala:semanticdb_provider")

    scala_toolchain(
        name = "%s_impl" % name,
        dep_providers = dep_providers,
        enable_semanticdb = enable_semanticdb,
        visibility = visibility,
        scala_version = scala_version,
        **kwargs
    )

    native.toolchain(
        name = name,
        toolchain = ":%s_impl" % name,
        toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
        visibility = visibility,
    )

def setup_scala_toolchains():
    for scala_version in SCALA_VERSIONS:
        setup_scala_toolchain(
            name = sanitize_version(scala_version) + "_toolchain",
            scala_version = scala_version,
            parser_combinators_deps = _parser_combinators_deps(scala_version),
            scala_compile_classpath = _scala_compile_classpath_deps(scala_version),
            scala_library_classpath = _scala_library_classpath_deps(scala_version),
            scala_macro_classpath = _scala_macro_classpath_deps(scala_version),
            scala_xml_deps = _scala_xml_deps(scala_version),
            semanticdb_deps = _scala_semanticdb_deps(scala_version),
            use_argument_file_in_runner = True,
        )
    setup_scala_toolchain(
        name = "unused_dependency_checker_error_toolchain",
        dependency_tracking_method = "ast-plus",
        scala_compile_classpath = _scala_compile_classpath_deps(),
        scala_library_classpath = _scala_library_classpath_deps(),
        scala_macro_classpath = _scala_macro_classpath_deps(),
        unused_dependency_checker_mode = "error",
    )
    setup_scala_toolchain(
        name = "minimal_direct_source_deps",
        dependency_mode = "plus-one",
        dependency_tracking_method = "ast",
        scala_compile_classpath = _scala_compile_classpath_deps(),
        scala_library_classpath = _scala_library_classpath_deps(),
        scala_macro_classpath = _scala_macro_classpath_deps(),
        strict_deps_mode = "error",
        unused_dependency_checker_mode = "error",
    )

def _deps_with_version_suffix(version, deps):
    return [dep + "_" + version for dep in deps[version[0:1]]]

def declare_dep_providers():
    declare_deps_provider(
        name = "scala_compile_classpath_provider",
        deps_id = "scala_compile_classpath",
        visibility = ["//visibility:public"],
        deps = _scala_compile_classpath_deps(),
    )

    declare_deps_provider(
        name = "scala_library_classpath_provider",
        deps_id = "scala_library_classpath",
        visibility = ["//visibility:public"],
        deps = _scala_library_classpath_deps(),
    )

    declare_deps_provider(
        name = "scala_macro_classpath_provider",
        deps_id = "scala_macro_classpath",
        visibility = ["//visibility:public"],
        deps = _scala_macro_classpath_deps(),
    )

    declare_deps_provider(
        name = "scala_xml_provider",
        deps_id = "scala_xml",
        visibility = ["//visibility:public"],
        deps = _scala_xml_deps(),
    )

    declare_deps_provider(
        name = "parser_combinators_provider",
        deps_id = "parser_combinators",
        visibility = ["//visibility:public"],
        deps = _parser_combinators_deps(),
    )

    declare_deps_provider(
        name = "semanticdb_provider",
        deps_id = "semanticdb",
        visibility = ["//visibility:public"],
        deps = _scala_semanticdb_deps(),
    )
