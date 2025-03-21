"""Macros to instantiate and register @rules_scala_toolchains"""

load("//jmh/toolchain:toolchain.bzl", "jmh_artifact_ids")
load("//junit:junit.bzl", "junit_artifact_ids")
load(
    "//scala/private:macros/scala_repositories.bzl",
    "scala_version_artifact_ids",
    "setup_scala_compiler_sources",
)
load(
    "//scala/scalafmt:scalafmt_repositories.bzl",
    "scalafmt_artifact_ids",
    "scalafmt_config",
)
load("//scala:scala_cross_version.bzl", "default_maven_server_urls")
load("//scala:toolchains_repo.bzl", "scala_toolchains_repo")
load("//scala_proto/default:repositories.bzl", "scala_proto_artifact_ids")
load("//scalatest:scalatest.bzl", "scalatest_artifact_ids")
load("//specs2:specs2.bzl", "specs2_artifact_ids")
load("//specs2:specs2_junit.bzl", "specs2_junit_artifact_ids")
load("//third_party/repositories:repositories.bzl", "repositories")
load(
    "//twitter_scrooge/toolchain:toolchain.bzl",
    "twitter_scrooge_artifact_ids",
    _TWITTER_SCROOGE_DEPS = "TOOLCHAIN_DEPS",
)
load("@rules_scala_config//:config.bzl", "SCALA_VERSIONS")

def _get_unknown_entries(entries, allowed_entries):
    return [e for e in entries if e not in allowed_entries]

def scala_toolchains(
        maven_servers = default_maven_server_urls(),
        overridden_artifacts = {},
        fetch_sources = False,
        validate_scala_version = True,
        scala_compiler_srcjars = {},
        scala = True,
        scalatest = False,
        junit = False,
        specs2 = False,
        scalafmt = False,
        scalafmt_default_config_path = ".scalafmt.conf",
        scala_proto = False,
        scala_proto_enable_all_options = False,
        jmh = False,
        twitter_scrooge = False,
        twitter_scrooge_deps = {}):
    """Instantiates rules_scala toolchains and all their dependencies.

    Provides a unified interface to configuring `rules_scala` both directly in a
    `WORKSPACE` file and in a Bazel module extension.

    Instantiates a repository containing all configured toolchains. Under
    `WORKSPACE`, you will need to call `scala_register_toolchains()`. Under
    Bzlmod, the `MODULE.bazel` file from `rules_scala` does this automatically.

    All arguments are optional.

    Args:
        maven_servers: Maven servers used to fetch dependency jar files
        overridden_artifacts: artifacts overriding the defaults for the
            configured Scala version, in the format:
            ```starlark
            "repo_name": {
                "artifact": "<maven coordinates>",
                "sha256": "<checksum>",
                "deps": [
                    "repository_labels_of_dependencies",
                ],
            }
            ```
            The default artifacts are defined by the
            `third_party/repositories/scala_*.bzl` file matching the Scala
            version.
        fetch_sources: whether to download dependency source jars
        validate_scala_version: Whether to check if the configured Scala
            versions matches the default versions supported by rules_scala. Only
            takes effect if `scala` is `True`.
        scala_compiler_srcjars: optional dictionary of Scala version string to
            compiler srcjar metadata dictionaries containing:
            - exactly one "label", "url", or "urls" key
            - optional "integrity" or "sha256" keys
        scala: whether to instantiate default Scala toolchains for configured
            Scala versions
        scalatest: whether to instantiate the ScalaTest toolchain
        junit: whether to instantiate the JUnit toolchain
        specs2: whether to instantiate the Specs2 JUnit toolchain
        scalafmt: whether to instantiate the Scalafmt toolchain
        scalafmt_default_config_path: the relative path to the default Scalafmt
            config file within the repository
        scala_proto: whether to instantiate the scala_proto toolchain
        scala_proto_enable_all_options: whether to instantiate the scala_proto
            toolchain with all options enabled; `scala_proto` must also be
            `True` for this to take effect
        jmh: whether to instantiate the Java Microbenchmarks Harness toolchain
        twitter_scrooge: whether to instantiate the twitter_scrooge toolchain
        twitter_scrooge_deps: dictionary of string to Label containing overrides
            for twitter_scrooge toolchain dependency providers with keys:
                libthrift
                scrooge_core
                scrooge_generator
                util_core
                util_logging
    """
    unknown_ts_deps = _get_unknown_entries(
        twitter_scrooge_deps,
        _TWITTER_SCROOGE_DEPS,
    )

    if unknown_ts_deps:
        fail("unknown twitter_scrooge_deps:", ", ".join(unknown_ts_deps))

    setup_scala_compiler_sources(scala_compiler_srcjars)

    if scalafmt:
        scalafmt_conf_target = "//:" + scalafmt_default_config_path
        scalafmt_config(name = "scalafmt_default", path = scalafmt_conf_target)

    if specs2:
        junit = True

    artifact_ids_to_fetch_sources = {}

    if scalatest:
        artifact_ids_to_fetch_sources.update({
            id: True
            for id in scalatest_artifact_ids()
        })
    if junit:
        artifact_ids_to_fetch_sources.update({
            id: True
            for id in junit_artifact_ids()
        })
    if specs2:
        artifact_ids_to_fetch_sources.update({
            id: True
            for id in specs2_artifact_ids() + specs2_junit_artifact_ids()
        })
    if jmh:
        artifact_ids_to_fetch_sources.update({
            id: False
            for id in jmh_artifact_ids()
        })
    if twitter_scrooge:
        artifact_ids_to_fetch_sources.update({
            id: False
            for id in twitter_scrooge_artifact_ids(**twitter_scrooge_deps)
        })

    for scala_version in SCALA_VERSIONS:
        version_specific_artifact_ids = {}

        if scala:
            version_specific_artifact_ids.update({
                id: fetch_sources
                for id in scala_version_artifact_ids(scala_version)
            })

        if scala_proto:
            version_specific_artifact_ids.update({
                id: True
                for id in scala_proto_artifact_ids(scala_version)
            })
        if scalafmt:
            version_specific_artifact_ids.update({
                id: fetch_sources
                for id in scalafmt_artifact_ids(scala_version)
            })

        all_artifacts = (
            artifact_ids_to_fetch_sources | version_specific_artifact_ids
        )

        repositories(
            scala_version = scala_version,
            for_artifact_ids = all_artifacts.keys(),
            maven_servers = maven_servers,
            fetch_sources = fetch_sources,
            fetch_sources_by_id = all_artifacts,
            # Note the internal macro parameter misspells "overriden".
            overriden_artifacts = overridden_artifacts,
            validate_scala_version = (scala and validate_scala_version),
        )

    scala_toolchains_repo(
        scalatest = scalatest,
        junit = junit,
        specs2 = specs2,
        scalafmt = scalafmt,
        scala_proto = scala_proto,
        scala_proto_enable_all_options = scala_proto_enable_all_options,
        jmh = jmh,
        twitter_scrooge = twitter_scrooge,
        twitter_scrooge_deps = twitter_scrooge_deps,
    )

def scala_register_toolchains():
    native.register_toolchains("@rules_scala_toolchains//...:all")

def scala_register_unused_deps_toolchains():
    native.register_toolchains(
        str(Label("//scala:unused_dependency_checker_error_toolchain")),
    )
