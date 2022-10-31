load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:providers.bzl", "declare_deps_provider")

def setup_scala_toolchain(
        name,
        scala_xml_deps,
        parser_combinators_deps,
        scala_compile_classpath,
        scala_library_classpath,
        scala_macro_classpath,
        visibility = ["//visibility:public"],
        **kwargs):
    scala_xml_provider = "%s_scala_xml_provider" % name
    parser_combinators_provider = "%s_parser_combinators_provider" % name
    scala_compile_classpath_provider = "%s_scala_compile_classpath_provider" % name
    scala_library_classpath_provider = "%s_scala_library_classpath_provider" % name
    scala_macro_classpath_provider = "%s_scala_macro_classpath_provider" % name

    print("XML", scala_xml_provider)

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

    declare_deps_provider(
        name = scala_xml_provider,
        deps_id = "scala_xml",
        visibility = visibility,
        deps = scala_xml_deps,
    )

    declare_deps_provider(
        name = parser_combinators_provider,
        deps_id = "parser_combinators",
        visibility = visibility,
        deps = parser_combinators_deps,
    )

    scala_toolchain(
        name = "%s_impl" % name,
        dep_providers = [
            scala_xml_provider,
            parser_combinators_provider,
            scala_compile_classpath_provider,
            scala_library_classpath_provider,
            scala_macro_classpath_provider,
        ],
        visibility = visibility,
        **kwargs
    )

    native.toolchain(
        name = name,
        toolchain = ":%s_impl" % name,
        toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
        visibility = visibility,
    )
