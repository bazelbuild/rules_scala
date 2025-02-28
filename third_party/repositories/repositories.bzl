load(
    "//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
    "extract_major_version",
    "version_suffix",
)
load(
    "//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)
load(
    "//third_party/repositories:scala_2_11.bzl",
    _artifacts_2_11 = "artifacts",
    _scala_version_2_11 = "scala_version",
)
load(
    "//third_party/repositories:scala_2_12.bzl",
    _artifacts_2_12 = "artifacts",
    _scala_version_2_12 = "scala_version",
)
load(
    "//third_party/repositories:scala_2_13.bzl",
    _artifacts_2_13 = "artifacts",
    _scala_version_2_13 = "scala_version",
)
load(
    "//third_party/repositories:scala_3_1.bzl",
    _artifacts_3_1 = "artifacts",
    _scala_version_3_1 = "scala_version",
)
load(
    "//third_party/repositories:scala_3_2.bzl",
    _artifacts_3_2 = "artifacts",
    _scala_version_3_2 = "scala_version",
)
load(
    "//third_party/repositories:scala_3_3.bzl",
    _artifacts_3_3 = "artifacts",
    _scala_version_3_3 = "scala_version",
)
load(
    "//third_party/repositories:scala_3_4.bzl",
    _artifacts_3_4 = "artifacts",
    _scala_version_3_4 = "scala_version",
)
load(
    "//third_party/repositories:scala_3_5.bzl",
    _artifacts_3_5 = "artifacts",
    _scala_version_3_5 = "scala_version",
)
load(
    "//third_party/repositories:scala_3_6.bzl",
    _artifacts_3_6 = "artifacts",
    _scala_version_3_6 = "scala_version",
)
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")

artifacts_by_major_scala_version = {
    "2.11": _artifacts_2_11,
    "2.12": _artifacts_2_12,
    "2.13": _artifacts_2_13,
    "3.1": _artifacts_3_1,
    "3.2": _artifacts_3_2,
    "3.3": _artifacts_3_3,
    "3.4": _artifacts_3_4,
    "3.5": _artifacts_3_5,
    "3.6": _artifacts_3_6,
}

scala_version_by_major_scala_version = {
    "2.11": _scala_version_2_11,
    "2.12": _scala_version_2_12,
    "2.13": _scala_version_2_13,
    "3.1": _scala_version_3_1,
    "3.2": _scala_version_3_2,
    "3.3": _scala_version_3_3,
    "3.4": _scala_version_3_4,
    "3.5": _scala_version_3_5,
    "3.6": _scala_version_3_6,
}

def repositories(
        scala_version = None,
        for_artifact_ids = [],
        maven_servers = default_maven_server_urls(),
        overriden_artifacts = {},
        fetch_sources = True,
        fetch_sources_by_id = {},
        validate_scala_version = False):
    """
    Downloads given artifacts.

    If `scala_version` is provided, artifacts will be downloaded for that Scala version.
    Also version-aware naming of repositories will be used (appending a suffix).
    Otherwise, the default Scala version is used and repository names have no suffix.
    """

    suffix = version_suffix(scala_version) if scala_version else ""
    scala_version = scala_version or SCALA_VERSION
    major_scala_version = extract_major_version(scala_version)

    if validate_scala_version:
        repository_scala_version = scala_version_by_major_scala_version[major_scala_version]
        default_version_matches = scala_version == repository_scala_version

        if not default_version_matches and len(overriden_artifacts) == 0:
            version_message = "Scala config (%s) version does not match repository version (%s)"
            fail(version_message % (scala_version, repository_scala_version))

    default_artifacts = artifacts_by_major_scala_version[major_scala_version]
    artifacts = dict(default_artifacts.items() + overriden_artifacts.items())
    for id in for_artifact_ids:
        if id not in artifacts:
            fail("artifact %s not in third_party/repositories/scala_%s.bzl" % (
                id,
                major_scala_version.replace(".", "_"),
            ))

        artifact_repo_name = id + suffix
        _scala_maven_import_external(
            name = artifact_repo_name,
            artifact = artifacts[id]["artifact"],
            artifact_sha256 = artifacts[id]["sha256"],
            licenses = ["notice"],
            server_urls = maven_servers,
            deps = [dep + suffix for dep in artifacts[id].get("deps", [])],
            runtime_deps = [
                dep + suffix
                for dep in artifacts[id].get("runtime_deps", [])
            ],
            testonly_ = artifacts[id].get("testonly", False),
            fetch_sources = fetch_sources_by_id.get(id, fetch_sources),
        )

        # For backward compatibility: non-suffixed repo pointing to the suffixed one,
        # See: https://github.com/bazelbuild/rules_scala/pull/1573
        # Hopefully we can deprecate and remove it one day.
        if suffix and scala_version == SCALA_VERSION:
            _alias_repository_wrapper(name = id, target = artifact_repo_name)

def _alias_repository_impl(rctx):
    """ Builds a repository containing just two aliases to the Scala Maven artifacts in the `target` repository. """
    format_kwargs = {
        # Replace with rctx.original_name once all supported Bazels have it
        "name": getattr(rctx, "original_name", rctx.attr.default_target_name),
        "target": rctx.attr.target,
    }
    rctx.file("BUILD", """alias(
    name = "{name}",
    actual = "@{target}",
    visibility = ["//visibility:public"],
)
""".format(**format_kwargs))
    rctx.file("jar/BUILD", """alias(
    name = "jar",
    actual = "@{target}//jar",
    visibility = ["//visibility:public"],
)
""".format(**format_kwargs))

_alias_repository = repository_rule(
    implementation = _alias_repository_impl,
    attrs = {
        # Remove once all supported Bazels have repository_ctx.original_name
        "default_target_name": attr.string(mandatory = True),
        "target": attr.string(mandatory = True),
    },
)

# Remove this macro and use `_alias_repository` directly once all supported
# Bazel versions support `repository_ctx.original_name`.
def _alias_repository_wrapper(**kwargs):
    """Wraps `_alias_repository` to pass `name` as `default_target_name`."""
    default_target_name = kwargs.pop("default_target_name", kwargs.get("name"))
    _alias_repository(default_target_name = default_target_name, **kwargs)
