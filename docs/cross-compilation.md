# Cross compilation support

Read [*Quick start*](#quick-start) for information on how to use cross
compilation. The remaining sections contain more detailed information, useful
especially for toolchain and rule developers.

## Quick start

The `scala_config` module extension (or`WORKSPACE` macro) creates the
`@io_bazel_rules_scala_config` repository. It accepts two parameters that
specify the the Scala versions supported within the project:

- `scala_version` – a single default version
- `scala_versions` – a list of versions supported or required by the project

__`MODULE.bazel`__

```py
# MODULE.bazel
scala_config = use_extension(
    "@rules_scala//scala/extensions:config.bzl",
    "scala_config",
)

scala_config.settings(
    scala_version = "2.13.15",
    # No need to include `scala_version` in `scala_versions`.
    scala_versions = [
        "2.11.12",
        "2.12.20",
        "3.1.3",
        "3.2.2",
        "3.3.5",
    ],
)
```

__`WORKSPACE` (Legacy support)__

```py
load("@rules_scala//:scala_config.bzl", "scala_config")

scala_config(
    scala_version = "3.1.3",
    # You _must_ include `scala_version` in `scala_versions`.
    scala_versions = [
        "2.11.12",
        "2.12.20",
        "2.13.15",
        "3.1.3",
        "3.2.2",
        "3.3.5",
    ],
)
```



The first parameter, `scala_version`, defines the default version of Scala to
use when building the project. Values from `scala_versions` can override the
default in one of two ways:

- The `--repo_env=SCALA_VERSION=...` command line flag overrides the default for
    the entire build.
- The `scala_version` build rule attribute overrides the Scala version used for
    a specific target and its dependencies.

Multiple rules, such as:

- [scala_library](../scala/private/rules/scala_library.bzl)
- [scala_binary](../scala/private/rules/scala_binary.bzl)
- [scala_repl](../scala/private/rules/scala_repl.bzl)
- [scala_test](../scala/private/rules/scala_test.bzl)

support `scala_version` overrides, e.g.:

```py
scala_library(
    name = ...
    ...
    scala_version = "2.12.18",
    ...
)
```

The above `scala_library` and all its dependencies will use the Scala 2.12.18
compiler, unless explicitly overridden by another target that depends on this
one.

## Version configuration

The `scala_config` module extension (or `WORKSPACE` macro) creates the
`@io_bazel_rules_scala_config` repository. Its generated `config.bzl` file
contains several variables, including:

- `SCALA_VERSION` – representing the default Scala version, e.g., `"3.3.1"`
- `SCALA_VERSIONS` – representing all configured Scala versions, e.g.,
    `["2.12.18", "3.3.1"]`

## Build settings

Each element of `SCALA_VERSIONS` corresponds to an allowed [build
setting](https://bazel.build/extending/config#user-defined-build-settings)
value.

### `scala_version`

The root package of `@io_bazel_rules_scala_config` defines the following build
setting (specifically, a ['string_setting()' from '@bazel_skylib'](
https://github.com/bazelbuild/bazel-skylib/blob/1.7.1/docs/common_settings_doc.md#string_setting)):

```py
string_setting(
    name = "scala_version",
    build_setting_default = "3.3.1",
    values = ["2.12.18", "3.3.1"],
    visibility = ["//visibility:public"],
)
```

This defines values allowed by the custom [user-defined
transition](https://bazel.build/extending/config#user-defined-transitions)
described in the [Requesting a specific version for a custom
'rule'](#custom-rule) section below.

### Config settings

For each Scala version in the above `string_setting()`, we have a [config
setting]( https://bazel.build/extending/config#build-settings-and-select):

```py
config_setting(
    name = "scala_version_3_3_1",
    flag_values = {":scala_version": "3.3.1"},
)
```

The `name` of the `config_setting` corresponds to `"scala_version" +
version_suffix(scala_version)`. One may use this config setting in `select()`
(e.g., to provide dependencies relevant to a currently used Scala version).

## Version-dependent behavior

Don't rely on `SCALA_VERSION` as it represents the default Scala version, not
necessarily the one that is currently requested.

There are two scenarios for customizing behavior based on a specific Scala
version.

### From toolchain

`@rules_scala//scala:toolchain_type` provides the `scala_version` field:

```py
def _rule_impl(ctx):
    ...
    ctx.toolchains["@rules_scala//scala:toolchain_type"].scala_version
    ...
```

### From config setting

In `BUILD` files, you need to use the config settings with `select()`. The
majority of use cases are covered by the `select_for_scala_version()` utility
macro. If more flexibility is needed, you can always write the select manually.

#### Using the `select_for_scala_version()` macro

```py
load(
    "@rules_scala//:scala_cross_version_select.bzl",
    "select_for_scala_version",
)

scala_library(
    ...
    srcs = select_for_scala_version(
        before_3_1 = [
            # for Scala version < 3.1
        ],
        between_3_1_and_3_2 = [
            # for 3.1 ≤ Scala version < 3.2
        ],
        between_3_2_and_3_3_1 = [
            # for 3.2 ≤ Scala version < 3.3.1
        ],
        since_3_3_1 = [
            # for 3.3.1 ≤ Scala version
        ],
    )
    ...
)
```

See the complete documentation in the [scala_cross_version_select.bzl](
../scala/scala_cross_version_select.bzl) file

#### Using a manually crafted `select()`

```py
deps = select({
    "@io_bazel_rules_scala_config//:scala_version_3_3_1": [...],
    ...
})
```

For more complex logic, define a macro taking a `scala_version` argument in a
`.bzl` file:

```py
def srcs(scala_version):
    if scala_version.startswith("2"):
        ...
    ...
```

and then `load()` the macro in a `BUILD` file:

```py
load(":my_macros.bzl", "srcs")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("@rules_scala//:scala_cross_version.bzl", "version_suffix")

_SCALA_VERSION_SETTING_PREFIX = "@io_bazel_rules_scala_config//:scala_version"

scala_library(
    ...
    srcs = select({
        SCALA_VERSION_SETTING_PREFIX + version_suffix(v): srcs(v)
        for v in SCALA_VERSIONS
    }),
    ...
)
```

## <a id="custom-rule"></a>Requesting a specific version for a custom `rule`

To enable a `rule` to use a version of Scala other than the default, first
assign the desired alternative versions to the `scala_versions` configuration
parameter. `scala_version_transition` from [`scala/scala_cross_version.bzl`](
../scala/scala_cross_version.bzl) then selects one of the `scala_versions` so
configured.

```py
def _scala_version_transition_impl(settings, attr):
    if attr.scala_version:
        return {"@io_bazel_rules_scala_config//:scala_version": attr.scala_version}
    else:
        return {}

scala_version_transition = transition(
    implementation = _scala_version_transition_impl,
    inputs = [],
    outputs = ["@io_bazel_rules_scala_config//:scala_version"],
)
```

In your own [`rule`](https://bazel.build/rules/lib/globals/bzl#rule) definition,
assign the `scala_version_transition` to the `cfg` attribute and include the
`toolchain_transition_attr` elements in `attrs`. For an example, see
`make_scala_library()` from [`scala/private/rules/scala_library.bzl`](
../scala/private/rules/scala_library.bzl):

```py
load(
    "@rules_scala//scala:scala_cross_version.bzl",
    "scala_version_transition",
    "toolchain_transition_attr",
)

...

_scala_library_attrs.update(toolchain_transition_attr)

def make_scala_library(*extras):
    return rule(
        attrs = _dicts.add(
            _scala_library_attrs,
            ...
        ),
        ...
        cfg = scala_version_transition,
        ...
    )
```

Now your `rule` can take a `scala_version` parameter to ensure it builds with a
specific Scala version. See [test_cross_build/version_specific/BUILD](
../test_cross_build/version_specific/BUILD) for examples of this, such as:

```py
scala_library(
    name = "since_3_3",
    srcs = ["since_3_3.scala"],
    scala_version = "3.3.5",
)

scala_library(
    name = "before_3_3",
    srcs = ["before_3_3.scala"],
    scala_version = "3.2.2",
)

# What's new in 3.2
scala_library(
    name = "since_3_2",
    srcs = ["since_3_2.scala"],
    scala_version = "3.2.2",
)

scala_library(
    name = "before_3_2",
    srcs = ["before_3_2.scala"],
    scala_version = "3.1.3",
)
```

## Toolchains

The standard [toolchain resolution](
https://bazel.build/extending/toolchains#toolchain-resolution)
procedure determines which toolchain to use for Scala targets.

Each toolchain should declare its compatibility with a specific Scala version by
using the `target_settings` attribute of the [`toolchain`](
https://bazel.build/reference/be/platforms-and-toolchains#toolchain) rule:

```py
toolchain(
    ...
    target_settings = ["@io_bazel_rules_scala_config//:scala_version_3_3_1"],
    ...
)
```

### Cross-build support tiers

`rules_scala` consists of many toolchains implementing various toolchain types.
Their support level for cross-build setups varies.

We can distinguish following tiers:

- No `target_settings` set – not migrated, will work on the default
    `SCALA_VERSION`; undefined behavior on other versions.
  - (all toolchains not mentioned elsewhere)

- `target_settings` set to the `SCALA_VERSION` – not fully migrated; will work
    only on the default `SCALA_VERSION` and will fail the toolchain resolution
    on other versions.
  - (no development in progress)

- Multiple toolchain instances with `target_settings` corresponding to each of
    `SCALA_VERSIONS` – fully migrated; will work in cross-build setup.
  - [the main Scala toolchain](/scala/BUILD)
  - [Scalafmt](/scala/scalafmt/BUILD)
  - [Scalatest](/testing/testing.bzl)
