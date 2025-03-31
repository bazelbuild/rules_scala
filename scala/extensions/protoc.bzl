"""Precompiled protocol compiler toolchains configuration

Usage:

```py
# MODULE.bazel

scala_protoc = use_extension(
    "@rules_scala//scala/extensions:protoc.bzl",
    "scala_protoc",
    dev_dependency = True,
)
use_repo(scala_protoc, "rules_scala_protoc_toolchains")

# If you need additional platforms:
scala_protoc.toolchains(
    platforms = ["linux-x86_64"],
)

# Register this toolchain before any others.
register_toolchains(
    "@rules_scala_protoc_toolchains//...:all",
    dev_dependency = True,
)
```

For documentation, see the `_tag_classes` dict, and the `_<TAG>_attrs` dict
corresponding to each `<TAG>` listed above.

See the `scala/private/macros/bzlmod.bzl` docstring for a description of
the defaults, attrs, and tag class dictionaries pattern employed here.
"""

load("//protoc:private/protoc_toolchains.bzl", "scala_protoc_toolchains")
load(
    "//scala/private:macros/bzlmod.bzl",
    "root_module_tags",
    "single_tag_values",
)

_TOOLCHAINS_REPO = "rules_scala_protoc_toolchains"

_toolchains_defaults = {
    "platforms": [],
}

_toolchains_attrs = {
    "platforms": attr.string_list(
        default = _toolchains_defaults["platforms"],
        doc = (
            "Operating system and architecture identifiers for " +
            "precompiled protocol compiler releases, taken from " +
            "protocolbuffers/protobuf releases file name suffixes. If " +
            "unspecified, will use the identifier matching the " +
            "`HOST_CONSTRAINTS` from `@platforms//host:constraints.bzl`." +
            " Only takes effect when" +
            "`--incompatible_enable_proto_toolchain_resolution` is " +
            "`True`."
        ),
    ),
}

_tag_classes = {
    "toolchains": tag_class(
        attrs = _toolchains_attrs,
        doc = "Precompiled compiler toolchain options",
    ),
}

def _scala_protoc_impl(module_ctx):
    if module_ctx.root_module_has_non_dev_dependency:
        fail("scala_protoc must be a dev_dependency")

    tags = root_module_tags(module_ctx, _tag_classes.keys())
    scala_protoc_toolchains(
        name = _TOOLCHAINS_REPO,
        **single_tag_values(module_ctx, tags.toolchains, _toolchains_defaults)
    )
    return module_ctx.extension_metadata(
        root_module_direct_deps = [],
        root_module_direct_dev_deps = [_TOOLCHAINS_REPO],
    )

scala_protoc = module_extension(
    implementation = _scala_protoc_impl,
    tag_classes = _tag_classes,
    doc = "Configures precompiled protocol compiler toolchains",
)
