"""Macros to configure scala versions and dependencies.

Creates the configuration repo @io_bazel_rules_scala_configuration.
"""

load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load("@bazel_skylib//lib:sets.bzl", _sets = "sets")

# default configuration: public for user examination (if desired?)
default_configuration = {
    "compatability_labels": True,
    "default": "2.11",
    "repositories": [
        "https://jcenter.bintray.com/",
        "https://maven.google.com",
        "https://repo1.maven.org/maven2",
    ],
    "scala": {
        "2.11": {
            "minor": "12",
        },
    },
    "scala-parser-combinators": "1.0.4",
    "scala-xml": "1.0.5",
    "scala_bootstrap_toolchain": {
        "scala_test_jvm_flags": [],
        "scalac_jvm_flags": [],
        "scalacopts": [],
    },
    "scala_toolchain": {
        "enable_code_coverage_aspect": "off",
        "plus_one_deps_mode": "off",
        "unused_dependency_checker_mode": "off",
    },
    "scalactic": "3.0.5",
    "scalatest": "3.0.5",
}

def _repo_impl(ctx):
    ctx.file(
        "BUILD.bazel",
        content = 'exports_files(["configuration.bzl"])',
        executable = False,
    )
    ctx.template(
        "configuration.bzl",
        ctx.attr._template,
        substitutions = {"%{STARLARK_STRING}": ctx.attr.starlark_string},
        executable = False,
    )

_repo = repository_rule(
    implementation = _repo_impl,
    attrs = {
        "starlark_string": attr.string(mandatory = True),
        "_template": attr.label(
            default = ":private/templates/configuration.bzl.tpl",
        ),
    },
)

def _merge_dicts(*dicts, exclude = None):
    """merge multiple dictionaries

    This is a lot like typical map merging but limited by the lack of
    recursion in starlark. It will merge values to one level only.

    Args:
      *dicts: the list of dicts to merge, sequentially
      exclude: a key to exclude from merging (merging may not work)

    """

    configuration = {}

    for input in dicts:
        keys = _sets.make(configuration.keys() + input.keys())

        if exclude and _sets.contains(keys, exclude):
            _sets.remove(keys, exclude)

        keys = _sets.to_list(keys)

        for key in keys:
            if key in input:
                field_type = type(input[key])
                if field_type == "string" or field_type == "list" or field_type == "bool":
                    configuration[key] = input[key]
                elif field_type == "dict":
                    configuration[key] = _dicts.add(
                        configuration.get(key, {}),
                        input[key],
                    )
                elif field_type == "NoneType":
                    configuration.pop(key)
                else:
                    fail([key, field_type])

    return configuration

def multiscala_configuration(configuration = default_configuration):
    """Primary entry point for configuration.

    Args:
      configuration: the configuration the user desires. Defaults to the one distributed.
    """

    configuration = _merge_dicts(default_configuration, configuration)

    # include default (true or false) for each target scala version rather than the selected default
    if not "default" in configuration and len(configuration["scala"].keys()) == 1:
        configuration = _dicts.add(
            configuration,
            {"default": configuration["scala"][configuration["scala"].keys()[0]]},
        )

    # since "scala" is a map key, we need to merge each item rather
    # than having a user-specified scala key completely override the
    # default.

    scala = {}

    for version in configuration["scala"].keys():
        dict = _merge_dicts(configuration, configuration["scala"][version], exclude = "scala")

        dict["scala"] = version
        dict["mvn"] = version.replace(".", "_")
        dict["complete"] = version + "." + dict["minor"]
        dict["default"] = True if dict.get("default") == version else False

        dict["bootstrap_toolchain"] = toolchain_label("bootstrap", version)

        scala[version] = dict

    configuration["scala"] = scala

    starlark_string = struct(**configuration).to_json()  # .replace(":null,", ":None,")

    _repo(
        name = "io_bazel_rules_scala_configuration",
        starlark_string = starlark_string,
    )

def scalac_label(version):
    return "//src/java/io/bazel/rulesscala/scalac:scalac_" + version.replace(".", "_")

def scalatest_runner_label(version):
    return "//src/java/io/bazel/rulesscala/scala_test:runner_" + version.replace(".", "_")

def scalatest_reporter_label(version):
    return "//scala/support:test_reporter_" + version.replace(".", "_")

def toolchain_label(toolchain, version, in_package = False):
    return "{package}{toolchain}_{version}_toolchain".format(
        package = "@io_bazel_rules_scala//unstable/multiscala:" if not in_package else "",
        toolchain = toolchain,
        version = version.replace(".", "_"),
    )

def native_toolchain_label(toolchain, version, in_package = False):
    return "{package}native_{toolchain}_{version}_toolchain".format(
        package = "@io_bazel_rules_scala//unstable/multiscala:" if not in_package else "",
        toolchain = toolchain,
        version = version.replace(".", "_"),
    )
