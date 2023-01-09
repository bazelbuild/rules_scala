load("//scala:scala_cross_version.bzl", "extract_major_version", "extract_minor_version")

def _default_scala_version():
    """return the scala version for use in maven coordinates"""
    return "2.12.14"

def _validate_supported_scala_version(scala_major_version, scala_minor_version):
    if scala_major_version == "2.11" and int(scala_minor_version) != 12:
        fail("Scala version must be 2.11.12 to use compiler dependency tracking with 2.11.")
    if scala_major_version == "2.12" and int(scala_minor_version) < 1:
        fail("Scala version must be newer or equal to 2.12.1 to use compiler dependency tracking.")

def _store_config(repository_ctx):
    scala_version = repository_ctx.os.environ.get(
        "SCALA_VERSION",
        repository_ctx.attr.scala_version,
    )

    enable_compiler_dependency_tracking = repository_ctx.os.environ.get(
        "ENABLE_COMPILER_DEPENDENCY_TRACKING",
        str(repository_ctx.attr.enable_compiler_dependency_tracking),
    )

    scala_major_version = extract_major_version(scala_version)

    if enable_compiler_dependency_tracking == "True":
        scala_minor_version = extract_minor_version(scala_version)
        _validate_supported_scala_version(scala_major_version, scala_minor_version)

    config_file_content = "\n".join([
        "SCALA_VERSION='" + scala_version + "'",
        "SCALA_MAJOR_VERSION='" + scala_major_version + "'",
        "ENABLE_COMPILER_DEPENDENCY_TRACKING=" + enable_compiler_dependency_tracking,
    ])

    repository_ctx.file("config.bzl", config_file_content)
    repository_ctx.file("BUILD")

_config_repository = repository_rule(
    implementation = _store_config,
    attrs = {
        "scala_version": attr.string(
            mandatory = True,
        ),
        "enable_compiler_dependency_tracking": attr.bool(
            mandatory = True,
        ),
    },
    environ = ["SCALA_VERSION", "ENABLE_COMPILER_DEPENDENCY_TRACKING"],
)

def scala_config(
        scala_version = _default_scala_version(),
        enable_compiler_dependency_tracking = False):
    _config_repository(
        name = "io_bazel_rules_scala_config",
        scala_version = scala_version,
        enable_compiler_dependency_tracking = enable_compiler_dependency_tracking,
    )
