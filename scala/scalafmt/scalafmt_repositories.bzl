load("//scala:scala_cross_version.bzl", "extract_major_version")
load("//scala_proto/default:repositories.bzl", "SCALAPB_COMPILE_ARTIFACT_IDS")

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

_SCALAFMT_DEPS = [
    "com_lihaoyi_fansi",
    "com_typesafe_config",
    "org_scala_lang_scalap",
    "org_scalameta_common",
    "org_scalameta_parsers",
    "org_scalameta_scalafmt_core",
    "org_scalameta_scalameta",
    "org_scalameta_trees",
    "org_typelevel_paiges_core",
] + SCALAPB_COMPILE_ARTIFACT_IDS

_SCALAFMT_DEPS_2_11 = [
    "com_geirsson_metaconfig_core",
    "com_geirsson_metaconfig_typesafe_config",
    "com_lihaoyi_pprint",
    "org_scalameta_fastparse",
    "org_scalameta_fastparse_utils",
]

_SCALAFMT_DEPS_2_12 = [
    "org_scalameta_mdoc_parser",
    "org_scalameta_metaconfig_core",
    "org_scalameta_metaconfig_pprint",
    "org_scalameta_metaconfig_typesafe_config",
    "org_scalameta_scalafmt_config",
    "org_scalameta_scalafmt_macros",
    "org_scalameta_scalafmt_sysops",
]

def scalafmt_artifact_ids(scala_version):
    major_version = extract_major_version(scala_version)

    if major_version == "2.11":
        return _SCALAFMT_DEPS + _SCALAFMT_DEPS_2_11

    extra_deps = []

    if major_version == "2.12":
        extra_deps.append("com_github_bigwheel_util_backports")
    else:
        extra_deps.append("io_bazel_rules_scala_scala_parallel_collections")

    return _SCALAFMT_DEPS + _SCALAFMT_DEPS_2_12 + extra_deps
