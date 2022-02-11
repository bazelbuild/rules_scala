load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION")

def scalafmt_default_config(path = ".scalafmt.conf"):
    build = []
    build.append("filegroup(")
    build.append("    name = \"config\",")
    build.append("    srcs = [\"{}\"],".format(path))
    build.append("    visibility = [\"//visibility:public\"],")
    build.append(")")
    native.new_local_repository(name = "scalafmt_default", build_file_content = "\n".join(build), path = "")

def scalafmt_repositories(
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {}):
    artifact_ids = [
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
    if SCALA_MAJOR_VERSION == "2.13" or SCALA_MAJOR_VERSION == "3.1":
        artifact_ids.append("io_bazel_rules_scala_scala_parallel_collections")

    repositories(
        for_artifact_ids = artifact_ids,
        maven_servers = maven_servers,
        fetch_sources = True,
        overriden_artifacts = overriden_artifacts,
    )
    native.register_toolchains("@io_bazel_rules_scala//scala/scalafmt:scalafmt_toolchain")
