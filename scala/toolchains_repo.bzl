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

def _stringify(value):
    """Wraps string values in double quotes for use in `BUILD` files."""
    return "\"%s\"" % value if type(value) == "string" else value

def _stringify_args(args, indent = " " * 4):
    """Formats a dict as `BUILD` rule or macro arguments."""
    return "".join([
        "%s%s = %s,\n" % (indent, k, _stringify(v))
        for k, v in args.items()
    ])

def _scala_toolchains_repo_impl(repository_ctx):
    repo_attr = repository_ctx.attr
    format_args = {
        "rules_scala_repo": Label("//:all").repo_name,
    }
    toolchains = {}

    if repo_attr.scala:
        toolchains["scala"] = _SCALA_TOOLCHAIN_BUILD
    if repo_attr.scala_proto:
        toolchains["scala_proto"] = _SCALA_PROTO_TOOLCHAIN_BUILD
        format_args["scala_proto_opts"] = _stringify_args({
            "default_gen_opts": repo_attr.scala_proto_options,
        })
    if repo_attr.jmh:
        toolchains["jmh"] = _JMH_TOOLCHAIN_BUILD
    if repo_attr.twitter_scrooge:
        toolchains["twitter_scrooge"] = _TWITTER_SCROOGE_TOOLCHAIN_BUILD
        format_args["twitter_scrooge_opts"] = _stringify_args(
            repo_attr.twitter_scrooge_deps,
        )

    testing_build_args = _generate_testing_toolchain_build_file_args(repo_attr)
    if testing_build_args != None:
        format_args.update(testing_build_args)
        toolchains["testing"] = _TESTING_TOOLCHAIN_BUILD

    if repo_attr.scalafmt:
        toolchains["scalafmt"] = _SCALAFMT_TOOLCHAIN_BUILD
        config_path = repository_ctx.path(repo_attr.scalafmt_default_config)

        if not config_path.exists:
            fail("Scalafmt default config file doesn't exist:", config_path)
        repository_ctx.symlink(config_path, "scalafmt/scalafmt.conf")

    # Generate a root package so that the `register_toolchains` call in
    # `MODULE.bazel` always succeeds.
    repository_ctx.file("BUILD", executable = False)

    for pkg, build in toolchains.items():
        repository_ctx.file(
            pkg + "/BUILD",
            content = build.format(**format_args),
            executable = False,
        )

scala_toolchains_repo = repository_rule(
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
        "scalafmt_default_config": attr.label(
            doc = "Default Scalafmt config file",
            allow_single_file = True,
        ),
        "scala_proto": attr.bool(
            doc = "Instantiate the scala_proto toolchain",
        ),
        "scala_proto_options": attr.string_list(
            doc = "Protobuf generator options",
        ),
        "jmh": attr.bool(
            doc = "Instantiate the Java Microbenchmarks Harness toolchain",
        ),
        "twitter_scrooge": attr.bool(
            doc = "Instantiate the twitter_scrooge toolchain",
        ),
        # attr.string_keyed_label_dict isn't available in Bazel 6
        "twitter_scrooge_deps": attr.string_dict(
            doc = "twitter_scrooge toolchain dependency provider overrides",
        ),
    },
)

_SCALA_TOOLCHAIN_BUILD = """
load(
    "@@{rules_scala_repo}//scala/private:macros/setup_scala_toolchain.bzl",
    "default_deps",
    "setup_scala_toolchain",
)
load("@@{rules_scala_repo}//scala:providers.bzl", "declare_deps_provider")
load("@@{rules_scala_repo}//scala:scala_cross_version.bzl", "version_suffix")
load("@rules_scala_config//:config.bzl", "SCALA_VERSION", "SCALA_VERSIONS")

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
load("@rules_scala_config//:config.bzl", "SCALA_VERSIONS")

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

filegroup(
    name = "config",
    srcs = [":scalafmt.conf"],
    visibility = ["//visibility:public"],
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
{scala_proto_opts})

declare_deps_provider(
    name = "scalapb_compile_deps_provider",
    deps_id = "scalapb_compile_deps",
    visibility = ["//visibility:public"],
    deps = DEFAULT_SCALAPB_COMPILE_DEPS + DEFAULT_SCALAPB_GRPC_DEPS,
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
{twitter_scrooge_opts})
"""
