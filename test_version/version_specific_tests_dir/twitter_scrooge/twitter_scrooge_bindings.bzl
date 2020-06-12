# Functions used for this particular example of resolving a dependency.
# Not necessary in general, you can pass any target label to `twitter_scrooge`.
load("@io_bazel_rules_scala//scala:scala_maven_import_external.bzl", "scala_maven_import_external")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "default_maven_server_urls", "extract_major_version", "scala_mvn_artifact")

# This is an example of how to customize `twitter_scrooge` to use alternative versions of its dependencies.
#
# Even though you could pass any label to `twitter_scrooge`, this particular example uses
# `scala_maven_import_external` to fetch different versions of the dependencies with custom labels,
# and initializes the `twitter_scrooge` system with those targets instead.
# Alternatively, you could pass your internal copies of the repo fetched via `http_archive`, `git_repository`,
# or a source target in your workspace.
#
# This code is used and tested in the integration test `test_twitter_scrooge_versions` in `./test_version.sh`.
load("@io_bazel_rules_scala//twitter_scrooge:twitter_scrooge.bzl", "twitter_scrooge")

def _resolve_dependency_version(dependency_name, dependency_version, sha, scala_major_version):
    custom_dependency_label = "custom_dependency_{}".format(dependency_name)
    scala_maven_import_external(
        name = custom_dependency_label,
        artifact = scala_mvn_artifact(
            "com.twitter:{}:{}".format(dependency_name, dependency_version),
            scala_major_version,
        ),
        artifact_sha256 = sha,
        licenses = ["notice"],
        server_urls = default_maven_server_urls(),
    )
    return "@{}".format(custom_dependency_label)

def twitter_scrooge_with_custom_dep_version(twitter_scrooge_deps_version, scala_version, version_shas):
    scala_major_version = extract_major_version(scala_version)

    scrooge_core_label = _resolve_dependency_version(
        "scrooge-core",
        twitter_scrooge_deps_version,
        version_shas[twitter_scrooge_deps_version]["scrooge-core"],
        scala_major_version,
    )
    scrooge_generator_label = _resolve_dependency_version(
        "scrooge-generator",
        twitter_scrooge_deps_version,
        version_shas[twitter_scrooge_deps_version]["scrooge-generator"],
        scala_major_version,
    )
    util_core_label = _resolve_dependency_version(
        "util-core",
        twitter_scrooge_deps_version,
        version_shas[twitter_scrooge_deps_version]["util-core"],
        scala_major_version,
    )
    util_logging_label = _resolve_dependency_version(
        "util-logging",
        twitter_scrooge_deps_version,
        version_shas[twitter_scrooge_deps_version]["util-logging"],
        scala_major_version,
    )
    twitter_scrooge(
        scala_version,
        scrooge_core = scrooge_core_label,
        scrooge_generator = scrooge_generator_label,
        util_core = util_core_label,
        util_logging = util_logging_label,
    )
