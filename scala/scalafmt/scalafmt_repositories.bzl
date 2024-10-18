load(
    "//scala:scala_cross_version.bzl",
    "extract_major_version",
    "version_suffix",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

def _scalafmt_config_impl(repository_ctx):
    config_path = repository_ctx.attr.path
    build = []
    build.append("filegroup(")
    build.append("    name = \"config\",")
    build.append("    srcs = [\"{}\"],".format(config_path.name))
    build.append("    visibility = [\"//visibility:public\"],")
    build.append(")\n")

    repository_ctx.file("BUILD", "\n".join(build), executable = False)
    repository_ctx.symlink(repository_ctx.path(config_path), config_path.name)

scalafmt_config = repository_rule(
    implementation = _scalafmt_config_impl,
    attrs = {
        "path": attr.label(mandatory = True, allow_single_file = True),
    },
)

def scalafmt_default_config(path = ".scalafmt.conf", **kwargs):
    scalafmt_config(name = "scalafmt_default", path = "//:" + path, **kwargs)

_SCALAFMT_DEPS = [
    "org_scalameta_common",
    "org_scalameta_fastparse",
    "org_scalameta_fastparse_utils",
    "org_scalameta_parsers",
    "org_scalameta_scalafmt_core",
    "org_scalameta_scalameta",
    "org_scalameta_trees",
    "org_typelevel_paiges_core",
    "com_typesafe_config",
    "org_scala_lang_scalap",
    "com_thesamet_scalapb_lenses",
    "com_thesamet_scalapb_scalapb_runtime",
    "com_lihaoyi_fansi",
    "com_lihaoyi_fastparse",
    "org_scalameta_fastparse_utils",
    "org_scala_lang_modules_scala_collection_compat",
    "com_lihaoyi_pprint",
    "com_lihaoyi_sourcecode",
    "com_google_protobuf_protobuf_java",
    "com_geirsson_metaconfig_core",
    "com_geirsson_metaconfig_typesafe_config",
]

def _artifact_ids(scala_version):
    major_version = extract_major_version(scala_version)
    geny = ["com_lihaoyi_geny"] if major_version != "2.11" else []
    parallel_collections = ["io_bazel_rules_scala_scala_parallel_collections"] if major_version == "2.13" or major_version.startswith("3") else []
    return _SCALAFMT_DEPS + geny + parallel_collections

def scalafmt_repositories(
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {}):
    for scala_version in SCALA_VERSIONS:
        repositories(
            scala_version = scala_version,
            for_artifact_ids = _artifact_ids(scala_version),
            maven_servers = maven_servers,
            overriden_artifacts = overriden_artifacts,
        )
    _register_scalafmt_toolchains()

def _register_scalafmt_toolchains():
    for scala_version in SCALA_VERSIONS:
        native.register_toolchains(str(Label(
            "//scala/scalafmt:scalafmt_toolchain" +
            version_suffix(scala_version),
        )))
