# Phase Scalafmt

## Contents

- [Overview](#overview)
- [How to set up](#how-to-set-up)
- [IntelliJ plugin support](#intellij-plugin-support)

## Overview

A phase extension `phase_scalafmt` can format Scala source code via [Scalafmt](https://scalameta.org/scalafmt/).

## How to set up

Add this snippet to `MODULE.bazel`:

```py
# MODULE.bazel
scala_deps = use_extension(
    "@rules_scala//scala/extensions:deps.bzl",
    "scala_deps",
)
scala_deps.scalafmt()
```

or to `WORKSPACE`:

```py
# WORKSPACE
load(
    "@rules_scala//scala:toolchains.bzl",
    "scala_register_toolchains",
    "scala_toolchains",
)

scala_toolchains(
    # Other toolchains settings...
    scalafmt = True,
)

scala_register_toolchains()
```

To add this phase to a rule, you have to pass the extension to a rule macro. Take `scala_binary` for example,

```py
load("//scala:advanced_usage/scala.bzl", "make_scala_binary")
load("//scala/scalafmt:phase_scalafmt_ext.bzl", "ext_scalafmt")

scalafmt_scala_binary = make_scala_binary(ext_scalafmt)
```

Then use `scalafmt_scala_binary` as normal.

The extension adds 2 additional attributes to the rule

- `format`: enable formatting
- `config`: the Scalafmt configuration file

When `format` is set to `true`, you can do

```txt
bazel run <TARGET>.format
```

to format the source code, and do

```txt
bazel run <TARGET>.format-test
```

to check the format (without modifying source code).

The extension provides a default configuration, but there are 2 ways to use
a custom configuration:

- Put `.scalafmt.conf` at the root of your workspace
- Pass `.scalafmt.conf` in via `scala_toolchains`:

    ```py
    # MODULE.bazel
    scala_deps.scalafmt(
        default_config = "//path/to/my/custom:scalafmt.conf",
    )

    # WORKSPACE
    scala_toolchains(
        # Other toolchains settings...
        scalafmt = {"default_config": "//path/to/my/custom:scalafmt.conf"},
    )
    ```

When using Scala 3, you must append `runner.dialect = scala3` to
`.scalafmt.conf`.

## IntelliJ plugin support

If you use IntelliJ Bazel plugin, then you should check the [Customizable Phase](/docs/customizable_phase.md#cooperation-with-intellij-plugin) page.

TL;DR: you should try naming your scalafmt rules the same way as the default `rules_scala` rules are named (in your own
scope), otherwise external dependency loading won't work in IntelliJ for your Scala targets. E.g.:

```python
# Using this rule won't let you see external dependencies:
scalafmt_scala_binary = make_scala_binary(ext_scalafmt)

# But this will work:
scala_binary = make_scala_binary(ext_scalafmt)
```
