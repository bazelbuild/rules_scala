"""Repository rule to instantiate @io_bazel_rules_scala_toolchains"""

def _scala_toolchains_repo_impl(repository_ctx):
    repo_attr = repository_ctx.attr
    format_args = {
        "rules_scala_repo": Label("//:all").repo_name,
    }
    toolchains = {}

    if repo_attr.scala:
        toolchains["scala"] = _SCALA_TOOLCHAIN_BUILD

    if len(toolchains) == 0:
        fail("no toolchains specified")

    for pkg, build in toolchains.items():
        repository_ctx.file(
            pkg + "/BUILD",
            content = build.format(**format_args),
            executable = False,
        )

_scala_toolchains_repo = repository_rule(
    implementation = _scala_toolchains_repo_impl,
    attrs = {
        "scala": attr.bool(default = True),
    },
)

def scala_toolchains_repo(name = "io_bazel_rules_scala_toolchains", **kwargs):
    _scala_toolchains_repo(
        name = name,
        **kwargs
    )

_SCALA_TOOLCHAIN_BUILD = """
load(
    "@@{rules_scala_repo}//scala/private:macros/setup_scala_toolchain.bzl",
    "default_deps",
    "setup_scala_toolchain",
)
load("@@{rules_scala_repo}//scala:providers.bzl", "declare_deps_provider")
load("@@{rules_scala_repo}//scala:scala_cross_version.bzl", "version_suffix")
load(
    "@io_bazel_rules_scala_config//:config.bzl",
    "SCALA_VERSION",
    "SCALA_VERSIONS",
)

[
    setup_scala_toolchain(
        name = "toolchain" + version_suffix(scala_version),
        scala_version = scala_version,
        use_argument_file_in_runner = True,
    )
    for scala_version in SCALA_VERSIONS
]

[
    declare_deps_provider(
        name = deps_id + "_provider",
        deps_id = deps_id,
        visibility = ["//visibility:public"],
        deps = default_deps(deps_id, SCALA_VERSION),
    )
    for deps_id in [
        "scala_xml",
        "parser_combinators",
        "scala_compile_classpath",
        "scala_library_classpath",
        "scala_macro_classpath",
        "semanticdb",
    ]
]
"""
