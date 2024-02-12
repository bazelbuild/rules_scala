load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

string_flag(
    name = "scala_version",
    build_setting_default = "",
    values = [
        "",
        "2.11.12",
        "2.12.18",
        "2.13.12",
        "3.1.0",
        "3.2.1",
        "3.3.1",
    ],
    visibility = ["//visibility:public"],
)

config_setting(
    name = "2_11_12",
    flag_values = {":scala_version": "2.11.12"},
)

config_setting(
    name = "2_12_18",
    flag_values = {":scala_version": "2.12.18"},
)

config_setting(
    name = "2_13_12",
    flag_values = {":scala_version": "2.13.12"},
)

config_setting(
    name = "3_1_0",
    flag_values = {":scala_version": "3.1.0"},
)

config_setting(
    name = "3_2_1",
    flag_values = {":scala_version": "3.2.1"},
)

config_setting(
    name = "3_3_1",
    flag_values = {":scala_version": "3.3.1"},
)
