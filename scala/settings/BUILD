package(default_visibility = ["//visibility:public"])

load("//scala/settings:stamp_settings.bzl", "stamp_scala_import")

stamp_scala_import(
    name = "stamp_scala_import",
    build_setting_default = True,
)

load("@bazel_skylib//rules:common_settings.bzl", "bool_flag", "string_flag", "string_list_flag")

bool_flag(
    name = "scala_toolchain_flags",
    build_setting_default = False,
)

string_flag(
    name = "dependency_mode",
    build_setting_default = "direct",
    values = [
        "direct",
        "plus-one",
        "transitive",
    ],
)

string_flag(
    name = "strict_deps_mode",
    build_setting_default = "default",
    values = [
        "off",
        "warn",
        "error",
        "default",
    ],
)

string_flag(
    name = "unused_dependency_checker_mode",
    build_setting_default = "off",
    values = [
        "off",
        "warn",
        "error",
    ],
)

string_flag(
    name = "compiler_deps_mode",
    build_setting_default = "off",
    values = [
        "off",
        "warn",
        "error",
    ],
)

string_flag(
    name = "dependency_tracking_method",
    build_setting_default = "default",
    values = [
        "ast-plus",
        "ast",
        "high-level",
        "default",
    ],
)

string_list_flag(
    name = "dependency_tracking_strict_deps_patterns",
    build_setting_default = [],
)

string_list_flag(
    name = "dependency_tracking_unused_deps_patterns",
    build_setting_default = [],
)

bool_flag(
    name = "enable_diagnostics_report",
    build_setting_default = False,
)

bool_flag(
    name = "enable_stats_file",
    build_setting_default = True,
)

bool_flag(
    name = "enable_semanticdb",
    build_setting_default = False,
)

bool_flag(
    name = "semanticdb_bundle_in_jar",
    build_setting_default = False,
)

bool_flag(
    name = "use_argument_file_in_runner",
    build_setting_default = False,
)
