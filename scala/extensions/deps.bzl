"""Configures builtin toolchains.

Provides the `scala_deps` module extension with the following tag classes:

- `settings`
- `overridden_artifact`
- `compiler_srcjar`
- `scala`
- `scalatest`
- `junit`
- `specs2`
- `scalafmt`
- `scala_proto`
- `twitter_scrooge`
- `jmh`

For documentation, see the `_{general,toolchain}_tag_classes` dicts and the
`_<TAG>_attrs` dict corresponding to each `<TAG>` listed above.

See the `scala/private/macros/bzlmod.bzl` docstring for a description of
the defaults, attrs, and tag class dictionaries pattern employed here.
"""

load(
    "//scala/private:macros/bzlmod.bzl",
    "repeated_tag_values",
    "root_module_tags",
    "single_tag_values",
)
load("//scala/private:toolchain_defaults.bzl", "TOOLCHAIN_DEFAULTS")
load("//scala:scala_cross_version.bzl", "default_maven_server_urls")
load("//scala:toolchains.bzl", "scala_toolchains")

_settings_defaults = {
    "maven_servers": default_maven_server_urls(),
    "fetch_sources": True,
    "validate_scala_version": True,
}

_settings_attrs = {
    "maven_servers": attr.string_list(
        default = _settings_defaults["maven_servers"],
        doc = "Maven servers used to fetch dependency jar files",
    ),
    "fetch_sources": attr.bool(
        default = _settings_defaults["fetch_sources"],
        doc = "Download dependency source jars",
    ),
    "validate_scala_version": attr.bool(
        default = _settings_defaults["validate_scala_version"],
        doc = (
            "Check if the configured Scala version matches " +
            "the default version supported by rules_scala. " +
            "Only takes effect when the builtin Scala toolchain is " +
            "instantiated via `scala_deps.scala()`."
        ),
    ),
}

_overridden_artifact_attrs = {
    "name": attr.string(
        doc = (
            "Repository name of artifact to override from " +
            "`third_party/repositories/scala_*.bzl`"
        ),
        mandatory = True,
    ),
    "artifact": attr.string(
        doc = "Maven coordinates of the overriding artifact",
        mandatory = True,
    ),
    "sha256": attr.string(
        doc = "SHA256 checksum of the `artifact`",
        mandatory = True,
    ),
    "deps": attr.string_list(
        doc = (
            "Repository names of artifact dependencies (with leading `@`), " +
            "if required"
        ),
    ),
}

_compiler_srcjar_attrs = {
    "version": attr.string(mandatory = True),
    "url": attr.string(),
    "urls": attr.string_list(),
    "label": attr.label(),
    "sha256": attr.string(),
    "integrity": attr.string(),
}

_scalafmt_defaults = TOOLCHAIN_DEFAULTS["scalafmt"]

_scalafmt_attrs = {
    "default_config": attr.label(
        default = _scalafmt_defaults["default_config"],
        doc = "The default config file for Scalafmt targets",
        allow_single_file = True,
    ),
}

_scala_proto_defaults = TOOLCHAIN_DEFAULTS["scala_proto"]

_scala_proto_attrs = {
    "default_gen_opts": attr.string_list(
        default = _scala_proto_defaults["default_gen_opts"],
        doc = "Protobuf options, like 'scala3_sources' or 'grpc'",
    ),
}

_twitter_scrooge_defaults = TOOLCHAIN_DEFAULTS["twitter_scrooge"]

_twitter_scrooge_attrs = {
    k: attr.label(default = v)
    for k, v in _twitter_scrooge_defaults.items()
}

# Tag classes affecting all toolchains.
_general_tag_classes = {
    "settings": tag_class(
        attrs = _settings_attrs,
        doc = "Settings affecting the configuration of all toolchains",
    ),
    "overridden_artifact": tag_class(
        attrs = _overridden_artifact_attrs,
        doc = """
Artifacts overriding the defaults for the configured Scala version.

Can be specified multiple times, but each `name` must be unique. The default
artifacts are defined by the `third_party/repositories/scala_*.bzl` file
matching the Scala version.
""",
    ),
    "compiler_srcjar": tag_class(
        attrs = _compiler_srcjar_attrs,
        doc = """
Metadata for locating compiler source jars.

Can be specified multiple times, but each `version` must be unique. Each
instance must contain:

    - `version`
    - exactly one of `label`, `url`, or `urls`
    - `integrity` or `sha256` are optional, but highly recommended
""",
    ),
}

# Tag classes for supported toolchains.
_toolchain_tag_classes = {
    "scala": tag_class(
        doc = "Configures the Scala toolchain",
    ),
    "scalatest": tag_class(
        doc = "Configures the ScalaTest",
    ),
    "junit": tag_class(
        doc = "Configures the JUnit toolchain",
    ),
    "specs2": tag_class(
        doc = "Configures the Specs2 toolchain",
    ),
    "scalafmt": tag_class(
        attrs = _scalafmt_attrs,
        doc = "Configures the Scalafmt toolchain",
    ),
    "scala_proto": tag_class(
        attrs = _scala_proto_attrs,
        doc = "Configures the scala_proto toolchain",
    ),
    "twitter_scrooge": tag_class(
        attrs = _twitter_scrooge_attrs,
        doc = "Configures the twitter_scrooge toolchain",
    ),
    "jmh": tag_class(
        doc = "Configures the Java Microbenchmark Harness",
    ),
}

def _toolchain_settings(module_ctx, tags, tc_names, toolchain_defaults):
    """Configures all builtin toolchains enabled throughout the module graph.

    Configures toolchain options for enabled toolchains that support them based
    on the root module's settings for each toolchain. In other words, it uses:

    - the root module's tag class settings, if present; and
    - the default tag class settings otherwise.

    This avoids trying to reconcile different toolchain settings across the
    module graph. Non root modules that require specific settings should either:

    - publish their required toolchain settings, or
    - define and register a custom toolchain instead.

    Args:
        module_ctx: the module context object
        tags: a tags object, presumably the result of `root_module_tags()`
        tc_names: names of all supported toolchains
        toolchain_defaults: a dict of `{toolchain_name: default options dict}`

    Returns:
        a dict of `{toolchain_name: bool or options dict}` to pass as keyword
            arguments to `scala_toolchains()`
    """
    toolchains = {k: False for k in tc_names}

    for mod in module_ctx.modules:
        values = {tc: len(getattr(mod.tags, tc)) != 0 for tc in toolchains}

        # Don't overwrite True values with False from another tag.
        toolchains.update({k: v for k, v in values.items() if v})

    for tc, defaults in toolchain_defaults.items():
        if toolchains[tc]:
            values = single_tag_values(module_ctx, getattr(tags, tc), defaults)
            toolchains[tc] = {k: v for k, v in values.items() if v != None}

    return toolchains

_tag_classes = _general_tag_classes | _toolchain_tag_classes

def _scala_deps_impl(module_ctx):
    tags = root_module_tags(module_ctx, _tag_classes.keys())
    tc_names = [tc for tc in _toolchain_tag_classes]

    scala_toolchains(
        overridden_artifacts = repeated_tag_values(
            tags.overridden_artifact,
            _overridden_artifact_attrs,
        ),
        scala_compiler_srcjars = repeated_tag_values(
            tags.compiler_srcjar,
            _compiler_srcjar_attrs,
        ),
        **(
            single_tag_values(module_ctx, tags.settings, _settings_defaults) |
            _toolchain_settings(module_ctx, tags, tc_names, TOOLCHAIN_DEFAULTS)
        )
    )

scala_deps = module_extension(
    implementation = _scala_deps_impl,
    tag_classes = _tag_classes,
    doc = """Selects and configures builtin toolchains.

If the root module explicitly uses the extension, it assumes responsibility for
selecting all required toolchains by insantiating the corresponding tag classes:

```py
scala_deps = use_extension(
    "@rules_scala//scala/extensions:deps.bzl",
    "scala_deps",
)
scala_deps.scala()
scala_deps.scala_proto()

dev_deps = use_extension(
    "@rules_scala//scala/extensions:deps.bzl",
    "scala_deps",
    dev_dependency = True,
)
dev_deps.scalafmt()
dev_deps.scalatest()

# And so on...
```
""",
)
