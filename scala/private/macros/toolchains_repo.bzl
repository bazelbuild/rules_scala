"""Repository rule to instantiate @io_bazel_rules_scala_toolchains"""

def _generate_testing_toolchain_build_file_args(repo_attr):
    framework_deps = {}

    if repo_attr.testing:
        framework_deps = {
            "scalatest": "SCALATEST_DEPS",
            "junit": "JUNIT_DEPS",
            "specs2": "SPECS2_DEPS",
            "specs2_junit": "SPECS2_JUNIT_DEPS",
        }
    if repo_attr.scalatest:
        framework_deps["scalatest"] = "SCALATEST_DEPS"
    if repo_attr.specs2:
        framework_deps["specs2"] = "SPECS2_DEPS"
        framework_deps["specs2_junit"] = "SPECS2_JUNIT_DEPS"
        framework_deps["junit"] = "JUNIT_DEPS"
    if repo_attr.junit:
        framework_deps["junit"] = "JUNIT_DEPS"

    if len(framework_deps) == 0:
        return None

    # The _TESTING_TOOLCHAIN_BUILD template expects that all framework keys are
    # present in the dictionary, so it can set unset framework classpath
    # parameters to `None`.
    return {
        "deps_symbols": "\",\n    \"".join(
            [s for s in framework_deps.values()],
        ),
        "scalatest": framework_deps.get("scalatest"),
        "junit": framework_deps.get("junit"),
        "specs2": framework_deps.get("specs2"),
        "specs2_junit": framework_deps.get("specs2_junit"),
    }

def _scala_toolchains_repo_impl(repository_ctx):
    repo_attr = repository_ctx.attr
    format_args = {
        "rules_scala_repo": Label("//:all").repo_name,
    }
    toolchains = {}

    if repo_attr.scala:
        toolchains["scala"] = _SCALA_TOOLCHAIN_BUILD

    testing_build_args = _generate_testing_toolchain_build_file_args(repo_attr)
    if testing_build_args != None:
        format_args.update(testing_build_args)
        toolchains["testing"] = _TESTING_TOOLCHAIN_BUILD

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
    doc = "Creates a repo containing Scala toolchain packages",
    attrs = {
        "scala": attr.bool(default = True),
        "scalatest": attr.bool(),
        "junit": attr.bool(),
        "specs2": attr.bool(),
        "testing": attr.bool(),
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

_TESTING_TOOLCHAIN_BUILD = """
load("@@{rules_scala_repo}//scala:scala_cross_version.bzl", "version_suffix")
load(
    "@@{rules_scala_repo}//testing:deps.bzl",
    "{deps_symbols}",
)
load(
    "@@{rules_scala_repo}//testing:testing.bzl",
    "setup_scala_testing_toolchain",
)
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

[
    setup_scala_testing_toolchain(
        name = "testing_toolchain" + version_suffix(scala_version),
        scala_version = scala_version,
        scalatest_classpath = {scalatest},
        junit_classpath = {junit},
        specs2_classpath = {specs2},
        specs2_junit_classpath = {specs2_junit},
    )
    for scala_version in SCALA_VERSIONS
]
"""
