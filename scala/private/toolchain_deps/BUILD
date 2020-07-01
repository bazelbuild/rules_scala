load(":toolchain_dep_rules.bzl", "common_toolchain_deps", "scala_toolchain_deps")

# dependencies from ScalacProvider
scala_toolchain_deps(
    name = "scala_compile_classpath",
    from_classpath = "default_repl_classpath",
    visibility = ["//visibility:public"],
)

scala_toolchain_deps(
    name = "scala_library_classpath",
    from_classpath = "default_classpath",
    visibility = ["//visibility:public"],
)

# dependencies from DepsInfo
common_toolchain_deps(
    name = "scala_xml",
    provider_id = "scala_xml",
    visibility = ["//visibility:public"],
)

common_toolchain_deps(
    name = "parser_combinators",
    provider_id = "parser_combinators",
    visibility = ["//visibility:public"],
)
