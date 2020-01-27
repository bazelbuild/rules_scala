load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load("@bazel_skylib//lib:sets.bzl", _sets = "sets")

default_configuration = {
    "scala": {
        "2.11": {
            "minor": "12",
        },
    },
    "scalatest": "3.0.5",
    "scalactic": "3.0.5",
    "scala-xml": "1.0.5",
    "scala-parser-combinators": "1.0.4",
    "repositories": [
        "https://jcenter.bintray.com/",
        "https://maven.google.com",
        "https://repo1.maven.org/maven2",
    ],
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
    "compatability_labels": True,
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
            default = ":configuration.bzl.tpl",
        ),
    },
)

def _merge_dicts(*dicts, exclude = None):
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
                else:
                    fail([key, field_type])
            else:
                configuration[key] = configuration[key]

    return configuration


def multiscala_configuration(user_configuration = default_configuration):
    configuration = _merge_dicts(default_configuration, user_configuration)

    if not "default" in configuration and len(configuration["scala"].keys()) == 1:
        configuration = _dicts.add(
            configuration,
            {"default": configuration["scala"][configuration["scala"].keys()[0]] }
        )

    scala = {}

    for version in configuration["scala"].keys():
        scala[version] = _merge_dicts(configuration, configuration["scala"][version], exclude = "scala")
        scala[version]["scala"] = version
        scala[version]["mvn"] = version.replace(".", "_")
        scala[version]["complete"] = version+"."+ scala[version]["minor"]
        scala[version]["default"] = True if scala[version].get("default") == version else False

    configuration["scala"] = scala

    starlark_string = struct(**configuration).to_json() # .replace(":null,", ":None,")

    _repo(
        name = "io_bazel_rules_scala_configuration",
        starlark_string = starlark_string,
    )

def multiscala_configure(configuration):
    _maybe_register_default_toolchains(configuration)

def _maybe_default(configuration):
    return configuration["scala"][configuration["default"]] if "default" in configuration else None

def toolchain_label(toolchain, version):
    return "{toolchain}_{version}_toolchain".format(toolchain = toolchain, version = version["mvn"])

def _maybe_register_default_toolchains(configuration):
    version = _maybe_default(configuration)
    if version:
        for toolchain in [
                # "bootstrap",
                "scala",
                # "scalatest"
        ]:
            native.register_toolchains("@io_bazel_rules_scala//unstable/multiscala:"+toolchain_label(toolchain, version))
