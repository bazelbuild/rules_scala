"""Macro to instantiate @io_bazel_rules_scala_toolchains"""

load(":macros/toolchains_repo.bzl", "scala_toolchains_repo")
load("//scala/private:macros/scala_repositories.bzl", "scala_repositories")
load("//scala:scala_cross_version.bzl", "default_maven_server_urls")

def scala_toolchains(
        maven_servers = default_maven_server_urls(),
        overridden_artifacts = {},
        load_rules_scala_dependencies = True,
        load_scala_toolchain_dependencies = True,
        fetch_sources = False,
        validate_scala_version = True,
        scala_compiler_srcjars = {},
        scala = True):
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
        scala: whether to instantiate the core Scala toolchain
    """
    num_toolchains = 0

    if scala:
        num_toolchains += 1
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

    if num_toolchains != 0:
        scala_toolchains_repo(
            scala = scala,
        )
