load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:providers.bzl", "declare_deps_provider")

def setup_scala_toolchain(
        name,
        scala_compile_classpath,
        scala_library_classpath,
        scala_macro_classpath,
        scala_xml_deps = None,
        parser_combinators_deps = None,
        scala_semanticdb_dep = None,
        enable_semanticdb = False,
        visibility = ["//visibility:public"],
        **kwargs):
    scala_xml_provider = "%s_scala_xml_provider" % name
    parser_combinators_provider = "%s_parser_combinators_provider" % name
    scala_compile_classpath_provider = "%s_scala_compile_classpath_provider" % name
    scala_library_classpath_provider = "%s_scala_library_classpath_provider" % name
    scala_macro_classpath_provider = "%s_scala_macro_classpath_provider" % name
    scala_semanticdb_dep_provider = "%s_scala_semanticdb_dep_provider" % name

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
        if scala_semanticdb_dep != None:
            declare_deps_provider(
                name = scala_semanticdb_dep_provider,
                deps_id = "scala_semanticdb",
                deps = [scala_semanticdb_dep],
                visibility = visibility,
            )

            dep_providers.append(scala_semanticdb_dep_provider)
        else:
            dep_providers.append("@io_bazel_rules_scala//scala:scala_semanticdb_provider")

    scala_toolchain(
        name = "%s_impl" % name,
        dep_providers = dep_providers,
        enable_semanticdb = enable_semanticdb,
        visibility = visibility,
        **kwargs
    )

    native.toolchain(
        name = name,
        toolchain = ":%s_impl" % name,
        toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
        visibility = visibility,
    )
