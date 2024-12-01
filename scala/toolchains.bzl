"""Macros to instantiate and register @io_bazel_rules_scala_toolchains"""

load("//junit:junit.bzl", "junit_artifact_ids")
load("//scala/private:macros/scala_repositories.bzl", "scala_repositories")
load("//scala/private:macros/toolchains_repo.bzl", "scala_toolchains_repo")
load("//scala:scala_cross_version.bzl", "default_maven_server_urls")
load("//scalatest:scalatest.bzl", "scalatest_artifact_ids")
load("//specs2:specs2.bzl", "specs2_artifact_ids")
load("//specs2:specs2_junit.bzl", "specs2_junit_artifact_ids")
load("//third_party/repositories:repositories.bzl", "repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

def scala_toolchains(
        maven_servers = default_maven_server_urls(),
        overridden_artifacts = {},
        load_rules_scala_dependencies = True,
        load_scala_toolchain_dependencies = True,
        fetch_sources = False,
        validate_scala_version = True,
        scala_compiler_srcjars = {},
        scalatest = False,
        junit = False,
        specs2 = False,
        testing = False):
    """Instantiates @io_bazel_rules_scala_toolchains and all its dependencies.

    Provides a unified interface to configuring rules_scala both directly in a
    `WORKSPACE` file and in a Bazel module extension.

    Instantiates the `@io_bazel_rules_scala_toolchains` repository. Under
    `WORKSPACE`, you will need to call `register_toolchains` at some point.
    Under Bzlmod, rules_scala does this automatically.

    ```starlark
    register_toolchains("@io_bazel_rules_scala_toolchains//...:all")
    ```

    All arguments are optional.

    Args:
        maven_servers: Maven servers used to fetch dependency jar files
        overridden_artifacts: specific dependency jar files to use instead of
            those from `maven_servers`, in the format:
            ```starlark
            "repo_name": {
                "artifact": "<maven coordinates>",
                "sha256": "<checksum>",
                "deps": [
                    "repository_names_of_dependencies",
                ],
            }
            ```
        load_rules_scala_dependencies: whether load rules_scala repository
            dependencies
        load_scala_toolchain_dependencies: whether to load repository
            dependencies of the core Scala language toolchain
        fetch_sources: whether to download dependency source jars
        validate_scala_version: whether to check if the configured Scala version
            matches the default version supported by rules_scala
        scala_compiler_srcjars: optional dictionary of Scala version string to
            compiler srcjar metadata dictionaries containing:
            - exactly one "label", "url", or "urls" key
            - optional "integrity" or "sha256" keys
        scalatest: whether to instantiate the Scalatest toolchain
        junit: whether to instantiate the JUnit toolchain
        specs2: whether to instantiate the Specs2 JUnit toolchain
        testing: whether to instantiate the Scalatest, JUnit, and Specs2 JUnit
            toolchains combined
    """
    scala_repositories(
        maven_servers = maven_servers,
        # Note the internal macro parameter misspells "overriden".
        overriden_artifacts = overridden_artifacts,
        load_dep_rules = load_rules_scala_dependencies,
        load_jar_deps = load_scala_toolchain_dependencies,
        fetch_sources = fetch_sources,
        validate_scala_version = validate_scala_version,
        scala_compiler_srcjars = scala_compiler_srcjars,
    )

    if testing:
        scalatest = True
        junit = True
        specs2 = True
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

    for scala_version in SCALA_VERSIONS:
        version_specific_artifact_ids = {}

        all_artifacts = (
            artifact_ids_to_fetch_sources | version_specific_artifact_ids
        )

        repositories(
            scala_version = scala_version,
            for_artifact_ids = all_artifacts.keys(),
            maven_servers = maven_servers,
            fetch_sources = fetch_sources,
            fetch_sources_by_id = all_artifacts,
            overriden_artifacts = overridden_artifacts,
            validate_scala_version = validate_scala_version,
        )

    scala_toolchains_repo(
        scalatest = scalatest,
        junit = junit,
        specs2 = specs2,
        testing = testing,
    )

def scala_register_toolchains():
    native.register_toolchains("@io_bazel_rules_scala_toolchains//...:all")

def scala_register_unused_deps_toolchains():
    native.register_toolchains(
        str(Label("//scala:unused_dependency_checker_error_toolchain")),
    )
