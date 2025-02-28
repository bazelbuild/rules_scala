"""Repository rule to instantiate @rules_scala_toolchains"""

def _generate_testing_toolchain_build_file_args(repo_attr):
    framework_deps = {}

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

_TWITTER_SCROOGE_ARGS = [
    "libthrift",
    "scrooge_core",
    "scrooge_generator",
    "util_core",
    "util_logging",
]

def _stringify_template_args(args, arg_names):
    return {
        arg: ("\"%s\"" % value if type(value) == "string" else value)
        for arg, value in {name: args.get(name) for name in arg_names}.items()
    }

def _scala_toolchains_repo_impl(repository_ctx):
    repo_attr = repository_ctx.attr
    format_args = {
        "rules_scala_repo": Label("//:all").repo_name,
        "proto_enable_all_options": repo_attr.scala_proto_enable_all_options,
    }
    toolchains = {}

    if repo_attr.scala:
        toolchains["scala"] = _SCALA_TOOLCHAIN_BUILD
    if repo_attr.scala_proto:
        toolchains["scala_proto"] = _SCALA_PROTO_TOOLCHAIN_BUILD
    if repo_attr.jmh:
        toolchains["jmh"] = _JMH_TOOLCHAIN_BUILD
    if repo_attr.twitter_scrooge:
        toolchains["twitter_scrooge"] = _TWITTER_SCROOGE_TOOLCHAIN_BUILD
        format_args.update(_stringify_template_args(
            repo_attr.twitter_scrooge_deps,
            _TWITTER_SCROOGE_ARGS,
        ))

    testing_build_args = _generate_testing_toolchain_build_file_args(repo_attr)
    if testing_build_args != None:
        format_args.update(testing_build_args)
        toolchains["testing"] = _TESTING_TOOLCHAIN_BUILD

    if repo_attr.scalafmt:
        toolchains["scalafmt"] = _SCALAFMT_TOOLCHAIN_BUILD

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
        "scala": attr.bool(
            doc = "Instantiate the Scala compiler toolchain",
            default = True,
        ),
        "scalatest": attr.bool(doc = "Instantiate the ScalaTest toolchain"),
        "junit": attr.bool(doc = "Instantiate the JUnit toolchain"),
        "specs2": attr.bool(doc = "Instantiate the Specs2 toolchain"),
        "scalafmt": attr.bool(doc = "Instantiate the Scalafmt toolchain"),
        "scala_proto": attr.bool(
            doc = "Instantiate the scala_proto toolchain",
        ),
        "scala_proto_enable_all_options": attr.bool(
            doc = (
                "Enable all scala_proto_options; " +
                "scala_proto must also be True for this to take effect"
            ),
        ),
        "jmh": attr.bool(
            doc = "Instantiate the Java Microbenchmarks Harness toolchain",
        ),
        "twitter_scrooge": attr.bool(
            doc = "Instantiate the twitter_scrooge toolchain",
        ),
        # attr.string_keyed_label_dict isn't available in Bazel 6
        "twitter_scrooge_deps": attr.string_dict(
            doc = (
                "overrides for twitter_scrooge toolchain dependency " +
                "providers with keys:\n" +
                "    libthrift\n" +
                "    scrooge_core\n" +
                "    scrooge_generator\n" +
                "    util_core\n" +
                "    util_logging"
            ),
        ),
    },
)

def scala_toolchains_repo(name = "rules_scala_toolchains", **kwargs):
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
load(
    "@@{rules_scala_repo}//scala:scala_cross_version.bzl",
    "repositories",
    "version_suffix",
)
load(
    "@@{rules_scala_repo}//testing:testing.bzl",
    "{deps_symbols}",
    "setup_scala_testing_toolchain",
)
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

[
    setup_scala_testing_toolchain(
        name = "testing_toolchain" + version_suffix(scala_version),
        scala_version = scala_version,
        scalatest_classpath = repositories(scala_version, {scalatest}),
        junit_classpath = repositories(scala_version, {junit}),
        specs2_classpath = repositories(scala_version, {specs2}),
        specs2_junit_classpath = repositories(scala_version, {specs2_junit}),
    )
    for scala_version in SCALA_VERSIONS
]
"""

_SCALAFMT_TOOLCHAIN_BUILD = """
load(
    "@@{rules_scala_repo}//scala/scalafmt/toolchain:setup_scalafmt_toolchain.bzl",
    "setup_scalafmt_toolchains",
)

setup_scalafmt_toolchains()
"""

_SCALA_PROTO_TOOLCHAIN_BUILD = """
load("@@{rules_scala_repo}//scala:providers.bzl", "declare_deps_provider")
load(
    "@@{rules_scala_repo}//scala_proto/default:default_deps.bzl",
    "DEFAULT_SCALAPB_COMPILE_DEPS",
    "DEFAULT_SCALAPB_GRPC_DEPS",
    "DEFAULT_SCALAPB_WORKER_DEPS",
)
load(
    "@@{rules_scala_repo}//scala_proto:toolchains.bzl",
    "setup_scala_proto_toolchains",
)

setup_scala_proto_toolchains(
    name = "scala_proto",
    enable_all_options = {proto_enable_all_options},
)

declare_deps_provider(
    name = "scalapb_compile_deps_provider",
    deps_id = "scalapb_compile_deps",
    visibility = ["//visibility:public"],
    deps = DEFAULT_SCALAPB_COMPILE_DEPS,
)

declare_deps_provider(
    name = "scalapb_grpc_deps_provider",
    deps_id = "scalapb_grpc_deps",
    visibility = ["//visibility:public"],
    deps = DEFAULT_SCALAPB_GRPC_DEPS,
)

declare_deps_provider(
    name = "scalapb_worker_deps_provider",
    deps_id = "scalapb_worker_deps",
    visibility = ["//visibility:public"],
    deps = DEFAULT_SCALAPB_WORKER_DEPS,
)
"""

_JMH_TOOLCHAIN_BUILD = """
load("@@{rules_scala_repo}//jmh/toolchain:toolchain.bzl", "setup_jmh_toolchain")

setup_jmh_toolchain(name = "jmh_toolchain")
"""

_TWITTER_SCROOGE_TOOLCHAIN_BUILD = """
load(
    "@@{rules_scala_repo}//twitter_scrooge/toolchain:toolchain.bzl",
    "setup_scrooge_toolchain",
)

setup_scrooge_toolchain(
    name = "scrooge_toolchain",
    libthrift = {libthrift},
    scrooge_core = {scrooge_core},
    scrooge_generator = {scrooge_generator},
    util_core = {util_core},
    util_logging = {util_logging},
)
"""
