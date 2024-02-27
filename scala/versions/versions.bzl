load("@bazel_skylib//rules:common_settings.bzl", "string_flag")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "extract_major_version")

_SCALA_VERSIONS = [
    "2.11.12",
    "2.12.18",
    "2.13.12",
    "3.1.0",
    "3.2.1",
    "3.3.1",
]

def config_settings():
    string_flag(
        name = "scala_version",
        build_setting_default = "",
        values = [""] + _SCALA_VERSIONS,
        visibility = ["//visibility:public"],
    )
    for scala_version in _SCALA_VERSIONS:
        native.config_setting(
            name = sanitize_version(scala_version),
            flag_values = {":scala_version": scala_version},
        )
        native.config_setting(
            name = sanitize_version(extract_major_version(scala_version)),
            flag_values = {":scala_version": scala_version},
        )

def _scala_version_transition_impl(settings, attr):
    if attr.scala_version:
        return {"//scala/versions:scala_version": attr.scala_version}
    else:
        return {}

scala_version_transition = transition(
    implementation = _scala_version_transition_impl,
    inputs = [],
    outputs = ["//scala/versions:scala_version"],
)

toolchain_transition_attr = {
    "scala_version": attr.string(),
    "_allowlist_function_transition": attr.label(
        default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
    ),
}

def sanitize_version(scala_version):
    return scala_version.replace(".", "_")
