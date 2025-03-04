load("//scala:scala_cross_version.bzl", "extract_major_version", "extract_minor_version", "version_suffix")

"""Default Scala version for use in Maven coordinates"""
DEFAULT_SCALA_VERSION = "2.12.20"

def _validate_supported_scala_version(scala_major_version, scala_minor_version):
    if scala_major_version == "2.11" and int(scala_minor_version) != 12:
        fail("Scala version must be 2.11.12 to use compiler dependency tracking with 2.11.")
    if scala_major_version == "2.12" and int(scala_minor_version) < 1:
        fail("Scala version must be newer or equal to 2.12.1 to use compiler dependency tracking.")

def _config_setting(scala_version):
    return """config_setting(
    name = "scala_version{version_suffix}",
    flag_values = {{":scala_version": "{version}"}},
    visibility = ["//visibility:public"],
)
""".format(version_suffix = version_suffix(scala_version), version = scala_version)

def _config_settings(scala_versions):
    return "".join([_config_setting(v) for v in scala_versions])

def _store_config(repository_ctx):
    # Default version
    scala_version = repository_ctx.os.environ.get(
        "SCALA_VERSION",
        repository_ctx.attr.scala_version,
    )

    # All versions supported
    scala_versions = repository_ctx.attr.scala_versions
    if not scala_versions:
        scala_versions = [scala_version]
    elif scala_version not in scala_versions:
        fail("You have to include the default Scala version (%s) in the `scala_versions` list." % scala_version)

    enable_compiler_dependency_tracking = repository_ctx.os.environ.get(
        "ENABLE_COMPILER_DEPENDENCY_TRACKING",
        str(repository_ctx.attr.enable_compiler_dependency_tracking),
    )

    scala_major_version = extract_major_version(scala_version)

    scala_minor_version = extract_minor_version(scala_version)
    if enable_compiler_dependency_tracking == "True":
        _validate_supported_scala_version(scala_major_version, scala_minor_version)

    config_file_content = "\n".join([
        "SCALA_VERSION='" + scala_version + "'",
        "SCALA_VERSIONS=" + str(scala_versions),
        "SCALA_MAJOR_VERSION='" + scala_major_version + "'",
        "SCALA_MINOR_VERSION='" + scala_minor_version + "'",
        "ENABLE_COMPILER_DEPENDENCY_TRACKING=" + enable_compiler_dependency_tracking,
    ])

    build_file_content = """load("@bazel_skylib//rules:common_settings.bzl", "string_setting")
string_setting(
    name = "scala_version",
    build_setting_default = "{scala_version}",
    values = {scala_versions},
    visibility = ["//visibility:public"],
)
""".format(scala_versions = scala_versions, scala_version = scala_version)
    build_file_content += _config_settings(scala_versions)

    repository_ctx.file("config.bzl", config_file_content)
    repository_ctx.file("BUILD", build_file_content)

_config_repository = repository_rule(
    implementation = _store_config,
    doc = "rules_scala configuration parameters",
    attrs = {
        "scala_version": attr.string(
            mandatory = True,
            doc = "Default Scala version",
        ),
        "scala_versions": attr.string_list(
            mandatory = True,
            doc = "List of all Scala versions to configure. Must include the default one.",
        ),
        "enable_compiler_dependency_tracking": attr.bool(
            mandatory = True,
        ),
    },
    environ = ["SCALA_VERSION", "ENABLE_COMPILER_DEPENDENCY_TRACKING"],
)

def scala_config(
        scala_version = DEFAULT_SCALA_VERSION,
        scala_versions = [],
        enable_compiler_dependency_tracking = False):
    _config_repository(
        name = "rules_scala_config",
        scala_version = scala_version,
        scala_versions = scala_versions,
        enable_compiler_dependency_tracking = enable_compiler_dependency_tracking,
    )
