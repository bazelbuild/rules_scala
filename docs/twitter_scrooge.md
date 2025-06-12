# Using the `twitter_scrooge` toolchain and rules

## Rules

```py
load("@rules_scala//thrift:thrift.bzl", "thrift_library")
load(
    "@rules_scala//twitter_scrooge/toolchain:toolchain.bzl",
    "setup_scrooge_toolchain",
)
load(
    "@rules_scala//twitter_scrooge:twitter_scrooge.bzl",
    "scrooge_java_library",
    "scrooge_scala_library",
)
```

## Examples

The [`//test/src/main/scala/scalarules/test/twitter_scrooge`][] package provides
extensive examples of `twitter_scrooge` rule usage.

## Toolchain configuration

### Default builtin toolchain

To use the builtin toolchain with its default dependencies under Bzlmod:

```py
# MODULE.bazel

scala_deps = use_extension("//scala/extensions:deps.bzl", "scala_deps")
dev_deps.scala()
dev_deps.twitter_scrooge()
```

And under `WORKSPACE`:

```py
# WORKSPACE
load(
    "@rules_scala//scala:toolchains.bzl",
    "scala_register_toolchains",
    "scala_toolchains",
)

scala_toolchains(twitter_scrooge = True)

scala_register_toolchains()
```

### Builtin toolchain dependency overrides

The [`examples/twitter_scrooge`][] repository shows how to configure the
toolchains for `twitter_scrooge` rules in both [`MODULE.bazel`][] and
[`WORKSPACE`][]. Both use [`rules_jvm_external`][] to import Maven artifacts for
overriding the builtin `twitter_scrooge` toolchain defaults.

### Defining a custom toolchain

[`examples/twitter_scrooge/BUILD`][] shows how to use `setup_scrooge_toolchain`
to define a custom `twitter_scrooge` toolchain with [`rules_jvm_external`][]
artifacts.

### More information

See the comments in the above [`examples/twitter_scrooge`][] files for
configuration details.

See the [Bazel manual on toolchain resolution](
https://bazel.build/extending/toolchains#toolchain-resolution) for guidance on
selecting a specific toolchain.

[`//test/src/main/scala/scalarules/test/twitter_scrooge`]: ../test/src/main/scala/scalarules/test/twitter_scrooge
[`examples/twitter_scrooge`]: ../examples/twitter_scrooge/
[`MODULE.bazel`]: ../examples/twitter_scrooge/MODULE.bazel
[`WORKSPACE`]: ../examples/twitter_scrooge/WORKSPACE
[`examples/twitter_scrooge/BUILD`]: ../examples/twitter_scrooge/BUILD
[`rules_jvm_external`]: https://github.com/bazel-contrib/rules_jvm_external
