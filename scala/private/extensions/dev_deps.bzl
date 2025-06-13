"""Repositories for testing rules_scala itself"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//scala:scala_cross_version.bzl", "default_maven_server_urls")
load("//scala:scala_maven_import_external.bzl", "java_import_external")
load(
    "//scala/private:macros/bzlmod.bzl",
    "root_module_tags",
    "single_tag_values",
)
load("//third_party/repositories:repositories.bzl", "repositories")

_BUILD_TOOLS_RELEASE = "8.2.1"
_BUILD_TOOLS_INTEGRITY = "sha256-UxGTl7vOHNfkxZDhF9zaNDwghhmd5ikyEGyAczUmwmE="

_settings_defaults = {
    "maven_servers": default_maven_server_urls(),
    "fetch_sources": False,
}

_settings_attrs = {
    "maven_servers": attr.string_list(
        default = _settings_defaults["maven_servers"],
    ),
    "fetch_sources": attr.bool(
        default = _settings_defaults["fetch_sources"],
    ),
}

_tag_classes = {
    "settings": tag_class(attrs = _settings_attrs),
}

def dev_deps_repositories(
        name = "unused_dev_deps_name",
        maven_servers = _settings_defaults["maven_servers"],
        fetch_sources = _settings_defaults["fetch_sources"]):
    """Instantiates internal only repos for development and testing

    Args:
        name: unused macro parameter to satisfy Buildifier lint rules
        maven_servers: servers to use when resolving Maven artifacts
        fetch_sources: retrieve Maven artifact sources when True
    """

    # gazelle is still getting `buildtools` from its `go.mod` file, which breaks
    # `bazel run //tools:lint_check` when we don't import it like this. See:
    # - https://github.com/bazel-contrib/bazel-gazelle/blob/v0.43.0/MODULE.bazel#L32-L44
    http_archive(
        name = "com_github_bazelbuild_buildtools",
        integrity = _BUILD_TOOLS_INTEGRITY,
        strip_prefix = "buildtools-%s" % _BUILD_TOOLS_RELEASE,
        url = (
            "https://github.com/bazelbuild/buildtools/archive/v%s.tar.gz" %
            _BUILD_TOOLS_RELEASE
        ),
    )

    # bazel's java_import_external has been altered in rules_scala to be a macro
    # based on jvm_import_external in order to allow for other jvm-language
    # imports (e.g. scala_import) the 3rd-party dependency below is using the
    # java_import_external macro in order to make sure no regression with the
    # original java_import_external
    java_import_external(
        name = "org_apache_commons_commons_lang_3_5_without_file",
        generated_linkable_rule_name = "linkable_org_apache_commons_commons_lang_3_5_without_file",
        jar_sha256 = "8ac96fc686512d777fca85e144f196cd7cfe0c0aec23127229497d1a38ff651c",
        jar_urls = ["https://repo.maven.apache.org/maven2/org/apache/commons/commons-lang3/3.5/commons-lang3-3.5.jar"],
        licenses = ["notice"],  # Apache 2.0
        neverlink = True,
        testonly_ = True,
    )

    repositories(
        fetch_sources = fetch_sources,
        fetch_sources_by_id = {
            # Required by test/shell/test_scala_import_source_jar.sh. Without
            # this, the first test will always fail, and the
            # `BAZEL_JVM_FETCH_SOURCES` environment variable has no effect.
            "com_google_guava_guava_21_0": True,
        },
        for_artifact_ids = [
            # test adding a scala jar:
            "com_twitter__scalding_date",
            # test of strict deps (scalac plugin UT + E2E)
            "com_google_guava_guava_21_0_with_file",
            "com_github_jnr_jffi_native",
            "org_apache_commons_commons_lang_3_5",
            "com_google_guava_guava_21_0",
            # test of import external
            # scala maven import external decodes maven artifacts to its parts
            # (group id, artifact id, packaging, version and classifier). To make sure
            # the decoding and then the download url composition are working the artifact example
            # must contain all the different parts and sha256s so the downloaded content will be
            # validated against it
            "org_springframework_spring_core",
            "org_springframework_spring_tx",
            "org_typelevel_kind_projector",
            # For testing that we don't include sources jars to the classpath
            "org_typelevel__cats_core",
        ],
        maven_servers = maven_servers,
    )

def _dev_deps_impl(module_ctx):
    """Instantiate internal only repos for development and testing"""
    tags = root_module_tags(module_ctx, _tag_classes.keys())
    settings = single_tag_values(module_ctx, tags.settings, _settings_defaults)
    dev_deps_repositories(**settings)

dev_deps = module_extension(
    implementation = _dev_deps_impl,
    tag_classes = _tag_classes,
    doc = "Configures repositories used only for internal testing",
)
