"""Configures builtin toolchains.

Provides the `scala_deps` module extension with the following tag classes:

- `settings`
- `scalafmt`
- `overridden_artifact`
- `compiler_srcjar`
- `toolchains`
- `twitter_scrooge`

For documentation, see the `_tag_classes` dict, and the `_<TAG>_attrs` dict
corresponding to each `<TAG>` listed above.

See the `scala/private/macros/bzlmod.bzl` docstring for a description of
the defaults, attrs, and tag class dictionaries pattern employed here.
"""

load(
    "//scala/private:macros/bzlmod.bzl",
    "repeated_tag_values",
    "root_module_tags",
    "single_tag_values",
)
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
            "Only takes effect if `scala_deps.toolchains(scala = True)`."
        ),
    ),
}

_scalafmt_defaults = {
    "default_config_path": ".scalafmt.conf",
}

_scalafmt_attrs = {
    "default_config_path": attr.string(
        default = _scalafmt_defaults["default_config_path"],
        doc = (
            "The relative path to the default Scalafmt config file " +
            "within the repository"
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

_toolchains_defaults = {
    "scalatest": False,
    "junit": False,
    "specs2": False,
    "scalafmt": False,
    "scala_proto": False,
    "scala_proto_options": [],
    "twitter_scrooge": False,
    "jmh": False,
}

_toolchains_attrs = {
    "scalatest": attr.bool(
        default = _toolchains_defaults["scalatest"],
        doc = "Register the Scalatest toolchain",
    ),
    "junit": attr.bool(
        default = _toolchains_defaults["junit"],
        doc = "Register the JUnit toolchain",
    ),
    "specs2": attr.bool(
        default = _toolchains_defaults["specs2"],
        doc = "Register the Specs2 JUnit toolchain",
    ),
    "scalafmt": attr.bool(
        default = _toolchains_defaults["scalafmt"],
        doc = (
            "Register the Scalafmt toolchain; configured by the " +
            "`scalafmt` tag"
        ),
    ),
    "scala_proto": attr.bool(
        default = _toolchains_defaults["scala_proto"],
        doc = "Register the scala_proto toolchain",
    ),
    "scala_proto_options": attr.string_list(
        default = _toolchains_defaults["scala_proto_options"],
        doc = (
            "Protobuf options, like 'scala3_sources' or 'grpc'; " +
            "`scala_proto` must also be `True` for this to take effect"
        ),
    ),
    "twitter_scrooge": attr.bool(
        default = _toolchains_defaults["twitter_scrooge"],
        doc = (
            "Use the twitter_scrooge toolchain; configured by the " +
            "`twitter_scrooge` tag"
        ),
    ),
    "jmh": attr.bool(
        default = _toolchains_defaults["jmh"],
        doc = "Use the jmh toolchain",
    ),
}

def _toolchains(mctx):
    result = dict(_toolchains_defaults)

    for mod in mctx.modules:
        toolchains_tags = mod.tags.toolchains
        values = single_tag_values(mctx, toolchains_tags, _toolchains_defaults)

        if mod.is_root:
            return values

        # Don't overwrite `True` values with `False` from another tag.
        result.update({k: v for k, v in values.items() if v})

    return result

_twitter_scrooge_defaults = {
    "libthrift": None,
    "scrooge_core": None,
    "scrooge_generator": None,
    "util_core": None,
    "util_logging": None,
}

_twitter_scrooge_attrs = {
    k: attr.label(default = v)
    for k, v in _twitter_scrooge_defaults.items()
}

_tag_classes = {
    "settings": tag_class(
        attrs = _settings_attrs,
        doc = "Settings affecting the configuration of all toolchains",
    ),
    "scalafmt": tag_class(
        attrs = _scalafmt_attrs,
        doc = "Options for the Scalafmt toolchain",
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
    "toolchains": tag_class(
        attrs = _toolchains_attrs,
        doc = """
Selects which builtin toolchains to use.

If the root module explicitly uses the extension, it assumes responsibility for
selecting all required toolchains. It can also disable any toolchains it doesn't
actually use.
""",
    ),
    "twitter_scrooge": tag_class(
        attrs = _twitter_scrooge_attrs,
        doc = (
            "Targets that override default `twitter_scrooge` toolchain " +
            "dependency providers"
        ),
    ),
}

def _scala_deps_impl(module_ctx):
    tags = root_module_tags(module_ctx, _tag_classes.keys())
    scalafmt = single_tag_values(module_ctx, tags.scalafmt, _scalafmt_defaults)
    scrooge_deps = single_tag_values(
        module_ctx,
        tags.twitter_scrooge,
        _twitter_scrooge_defaults,
    )

    scala_toolchains(
        overridden_artifacts = repeated_tag_values(
            tags.overridden_artifact,
            _overridden_artifact_attrs,
        ),
        scala_compiler_srcjars = repeated_tag_values(
            tags.compiler_srcjar,
            _compiler_srcjar_attrs,
        ),
        # `None` breaks the `attr.string_dict` in `scala_toolchains_repo`.
        twitter_scrooge_deps = {k: v for k, v in scrooge_deps.items() if v},
        **(
            single_tag_values(module_ctx, tags.settings, _settings_defaults) |
            {"scalafmt_%s" % k: v for k, v in scalafmt.items()} |
            _toolchains(module_ctx)
        )
    )

scala_deps = module_extension(
    implementation = _scala_deps_impl,
    tag_classes = _tag_classes,
    doc = "Configures builtin toolchains",
)
