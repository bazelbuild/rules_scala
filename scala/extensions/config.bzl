"""Core `rules_scala` configuration

Provides the `scala_config` module extension with the `settings` tag class.
See the `_settings_attrs` dict for documentation.
"""

load(
    "//:scala_config.bzl",
    "DEFAULT_SCALA_VERSION",
    _scala_config = "scala_config",
)
load(
    "//scala/private:macros/bzlmod.bzl",
    "root_module_tags",
    "single_tag_values",
)

_settings_defaults = {
    "scala_version": DEFAULT_SCALA_VERSION,
    "scala_versions": [],
    "enable_compiler_dependency_tracking": False,
}

_settings_attrs = {
    "scala_version": attr.string(
        default = _settings_defaults["scala_version"],
        doc = (
            "Scala version used by the default toolchain. " +
            "Overridden by the `SCALA_VERSION` environment variable."
        ),
    ),
    "scala_versions": attr.string_list(
        default = _settings_defaults["scala_versions"],
        doc = (
            "Other Scala versions used in cross build targets " +
            "(specified by the `scala_version` attribute of `scala_*` rules)"
        ),
    ),
    "enable_compiler_dependency_tracking": attr.bool(
        default = _settings_defaults["enable_compiler_dependency_tracking"],
        doc = (
            "Enables `scala_toolchain` dependency tracking features. " +
            "Overridden by the `ENABLE_COMPILER_DEPENDENCY_TRACKING` " +
            "environment variable."
        ),
    ),
}

_tag_classes = {
    "settings": tag_class(
        attrs = _settings_attrs,
        doc = "Core `rules_scala` parameters",
    ),
}

def _scala_config_impl(module_ctx):
    tags = root_module_tags(module_ctx, _tag_classes.keys())
    settings = single_tag_values(module_ctx, tags.settings, _settings_defaults)

    menv = module_ctx.os.environ
    version = menv.get("SCALA_VERSION", settings["scala_version"])
    versions = {version: None} | {v: None for v in settings["scala_versions"]}

    _scala_config(
        scala_version = version,
        scala_versions = versions.keys(),
        enable_compiler_dependency_tracking = menv.get(
            "ENABLE_COMPILER_DEPENDENCY_TRACKING",
            settings["enable_compiler_dependency_tracking"],
        ),
    )

scala_config = module_extension(
    implementation = _scala_config_impl,
    tag_classes = _tag_classes,
    environ = ["SCALA_VERSION", "ENABLE_COMPILER_DEPENDENCY_TRACKING"],
    doc = (
        "Configures core `rules_scala` parameters and exports them via the " +
        "`@rules_scala_config` repository"
    ),
)
