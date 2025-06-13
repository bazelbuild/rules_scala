"""Macros to instantiate and register @rules_scala_toolchains"""

load("@rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("//jmh/toolchain:toolchain.bzl", "jmh_artifact_ids")
load("//junit:junit.bzl", "junit_artifact_ids")
load("//scala:scala_cross_version.bzl", "default_maven_server_urls")
load("//scala:toolchains_repo.bzl", "scala_toolchains_repo")
load(
    "//scala/private:macros/scala_repositories.bzl",
    "scala_version_artifact_ids",
    "setup_scala_compiler_sources",
)
load("//scala/private:toolchain_defaults.bzl", "TOOLCHAIN_DEFAULTS")
load("//scala/scalafmt:scalafmt_repositories.bzl", "scalafmt_artifact_ids")
load("//scala_proto/default:repositories.bzl", "scala_proto_artifact_ids")
load("//scalatest:scalatest.bzl", "scalatest_artifact_ids")
load("//specs2:specs2.bzl", "specs2_artifact_ids")
load("//specs2:specs2_junit.bzl", "specs2_junit_artifact_ids")
load("//third_party/repositories:repositories.bzl", "repositories")
load(
    "//twitter_scrooge/toolchain:toolchain.bzl",
    "twitter_scrooge_artifact_ids",
)

_DEFAULT_TOOLCHAINS_REPO_NAME = "rules_scala_toolchains"

def _toolchain_opts(tc_arg):
    """Converts a toolchain parameter to a (bool, dict of options).

    Used by `scala_toolchains` to parse toolchain arguments as True, False,
    None, or a dict of options.

    Args:
        tc_arg: a bool, dict, or None

    Returns:
        a bool indicating whether the toolchain is enabled, and a dict
            containing any provided toolchain options
    """
    if tc_arg == False or tc_arg == None:
        return False, {}
    return True, ({} if tc_arg == True else tc_arg)

def _process_toolchain_options(toolchain_defaults, **kwargs):
    """Checks the validity of toolchain options and provides defaults.

    Updates each toolchain option dictionary with defaults for every missing
    entry.

    Args:
        toolchain_defaults: a dict of `{toolchain_name: default options dict}`
        **kwargs: keyword arguments of the form `toolchain_name = options_dict`

    Returns:
        a list of error messages for invalid toolchains or options
    """
    errors = []

    for tc, options in kwargs.items():
        defaults = toolchain_defaults.get(tc, None)

        if defaults == None:
            errors.append("unknown toolchain or doesn't have defaults: " + tc)
            continue

        unexpected = [a for a in options if a not in defaults]

        if unexpected:
            plural = "s" if len(unexpected) != 1 else ""
            errors.append(
                "unexpected %s toolchain attribute%s: " % (tc, plural) +
                ", ".join(unexpected),
            )

        options.update({
            k: v
            for k, v in defaults.items()
            if k not in options and v != None
        })

    return errors

def scala_toolchains(
        name = _DEFAULT_TOOLCHAINS_REPO_NAME,
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
        scala_proto = False,
        jmh = False,
        twitter_scrooge = False):
    """Instantiates rules_scala toolchains and all their dependencies.

    Provides a unified interface to configuring `rules_scala` both directly in a
    `WORKSPACE` file and in a Bazel module extension.

    Instantiates a repository containing all configured toolchains. Under
    `WORKSPACE`, you will need to call `scala_register_toolchains()`. Under
    Bzlmod, the `MODULE.bazel` file from `rules_scala` does this automatically.

    All arguments are optional.

    Args:
        name: Name of the generated toolchains repository
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
        scalafmt: boolean or dictionary of Scalafmt options:
            - default_config: default Scalafmt config file target
        scala_proto: boolean or dictionary of `setup_scala_proto_toolchain()`
            options
        jmh: whether to instantiate the Java Microbenchmarks Harness toolchain
        twitter_scrooge: bool or dictionary of `setup_scrooge_toolchain()`
            options
    """
    scalafmt, scalafmt_options = _toolchain_opts(scalafmt)
    scala_proto, scala_proto_options = _toolchain_opts(scala_proto)
    twitter_scrooge, twitter_scrooge_options = _toolchain_opts(twitter_scrooge)

    errors = _process_toolchain_options(
        TOOLCHAIN_DEFAULTS,
        scalafmt = scalafmt_options,
        scala_proto = scala_proto_options,
        twitter_scrooge = twitter_scrooge_options,
    )
    if errors:
        fail("\n".join(errors))

    setup_scala_compiler_sources(scala_compiler_srcjars)

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
            for id in twitter_scrooge_artifact_ids(**twitter_scrooge_options)
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
        name = name,
        scalatest = scalatest,
        junit = junit,
        specs2 = specs2,
        scalafmt = scalafmt,
        scalafmt_default_config = scalafmt_options["default_config"],
        scala_proto = scala_proto,
        scala_proto_options = scala_proto_options["default_gen_opts"],
        jmh = jmh,
        twitter_scrooge = twitter_scrooge,
        # When we _really_ drop Bazel 6 entirely, this attribute can become an
        # attr.string_keyed_label_dict, and this conversion won't be necessary.
        twitter_scrooge_deps = {
            k: str(v)
            for k, v in twitter_scrooge_options.items()
        },
    )

def scala_register_toolchains(name = _DEFAULT_TOOLCHAINS_REPO_NAME):
    native.register_toolchains("@%s//...:all" % name)

def scala_register_unused_deps_toolchains():
    native.register_toolchains(
        "//scala:unused_dependency_checker_error_toolchain",
    )
