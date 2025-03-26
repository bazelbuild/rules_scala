"""Precompiled protocol compiler toolchains repository rule.

To use this under `WORKSPACE`:

```py
# WORKSPACE

# Register this toolchain before any others.
register_toolchains("@rules_scala_protoc_toolchains//...:all")

load("@platforms//host:extension.bzl", "host_platform_repo")

# Instantiates the `@host_platform` repo to work around:
# - https://github.com/bazelbuild/bazel/issues/22558
host_platform_repo(name = "host_platform")

# ...load `com_google_protobuf`, `rules_proto`, etc...

load("@rules_scala//protoc:toolchains.bzl", "scala_protoc_toolchains")

# The name can be anything, but we recommend `rules_scala_protoc_toolchains`.
# Only include `platforms` if you need additional platforms other than the
# automatically detected host platform.
scala_protoc_toolchains(
    name = "rules_scala_protoc_toolchains",
    platforms = ["linux-x86_64"],
)
```
"""

load(":private/protoc_toolchains.bzl", _toolchains = "scala_protoc_toolchains")

scala_protoc_toolchains = _toolchains
