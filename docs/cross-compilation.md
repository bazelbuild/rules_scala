# Cross compilation support

Read *Quick start* for an information on how to use cross compilation.
The remaining sections contain more detailed information, useful especially for toolchain & rule developers.

## Quick start
`scala_config` repository rule accepts two parameters related to Scala version:
* `scala_version` – a single, default version;
* `scala_versions` – a list of versions to make available for use.

The first one, `scala_version`, will be used as a default, but it can be overridden for specific targets for any version from the `scala_versions`.

Multiple rules, such as:
- [scala_library](/scala/private/rules/scala_library.bzl)
- [scala_binary](/scala/private/rules/scala_binary.bzl)
- [scala_repl](/scala/private/rules/scala_repl.bzl)
- [scala_test](/scala/private/rules/scala_test.bzl)

support such override via the `scala_version` attribute, e.g.:
```starlark
scala_library(
    name = ...
    ...
    scala_version = "2.12.19",
    ...
)
```

For this library and all its dependencies 2.12.19 compiler will be used, unless explicitly overridden again in another target.

## Version configuration

`scala_config` creates the repository `@io_bazel_rules_scala_config`.
File created there, `config.bzl`, consists of many variables. In particular:
* `SCALA_VERSION` – representing the default Scala version, e.g. `"3.3.3"`;
* `SCALA_VERSIONS` – representing all configured Scala versions, e.g. `["2.12.19", "3.3.3"]`.


## Build settings
Configured `SCALA_VERSIONS` correspond to allowed values of [build setting](https://bazel.build/extending/config#user-defined-build-setting).

### `scala_version`
`@io_bazel_rules_scala_config` in its root package defines the following build setting:
```starlark
string_setting(
    name = "scala_version",
    build_setting_default = "3.3.3",
    values = ["3.3.3"],
    visibility = ["//visibility:public"],
)
...
```
This build setting can be subject of change by [transitions](https://bazel.build/extending/config#user-defined-transitions) (within allowed `values`).

### Config settings
Then for each Scala version we have a [config setting](https://bazel.build/extending/config#build-settings-and-select):
```starlark
config_setting(
    name = "scala_version_3_3_1",
    flag_values = {":scala_version": "3.3.3"},
)
...
```
The `name` of `config_setting` corresponds to `"scala_version" + version_suffix(scala_version)`.
One may use this config setting in `select()` e.g. to provide dependencies relevant to a currently used Scala version.


## Version-dependent behavior
Don't rely on `SCALA_VERSION` as it represents the default Scala version, not necessarily the one that is currently requested.

If you need to customize the behavior for specific Scala version, there are two scenarios.

### From toolchain
If you have an access to the Scala toolchain (`@io_bazel_rules_scala//scala:toolchain_type`), there is `scala_version` field provided in there:
```starlark
def _rule_impl(ctx):
    ...
    ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].scala_version
    ...
```

### From config setting
In BUILD files, you need to use the config settings with `select()`.
Majority of use cases is covered by the `select_for_scala_version` utility macro.
If more flexibility is needed, you can always write the select manually.

#### With select macro
See example usage of the `select_for_scala_version`:

```starlark
load("@io_bazel_rules_scala//:scala_cross_version_select.bzl", "select_for_scala_version")

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
            # for 3.2 ≤ Scala version < 3.3.3
        ],
        since_3_3_1 = [
            # for 3.3.3 ≤ Scala version
        ],
    )
    ...
)
```

See complete documentation in the [scala_cross_version_select.bzl](/scala/scala_cross_version_select.bzl) file

#### Manually
An example usage of `select()` to provide custom dependency for specific Scala version:
```starlark
deps = select({
    "@io_bazel_rules_scala_config//:scala_version_3_3_1": [...],
    ...
})
```

For more complex logic, you can extract it to a `.bzl` file:
```starlark
def srcs(scala_version):
    if scala_version.startswith("2"):
        ...
    ...
```
and then in the `BUILD` file:
```starlark
load("@io_bazel_rules_scala//:scala_cross_version.bzl", "version_suffix")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("....bzl", "srcs")

scala_library(
    ...
    srcs = select({
        "@io_bazel_rules_scala_config//:scala_version" + version_suffix(v): srcs(v)
        for v in SCALA_VERSIONS
    }), 
    ...
)
```


## Requesting specific version
To use other than default version of Scala, you need to change the current `@io_bazel_rules_scala_config//:scala_version` build setting.

Simple transition, setting the Scala version to one found in `scala_version` attribute:
```starlark
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

To use it in a rule, use the `scala_version_transition` as `cfg` and use `toolchain_transition_attr` in `attrs`:
```starlark
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "scala_version_transition", "toolchain_transition_attr")

_scala_library_attrs.update(toolchain_transition_attr)

def make_scala_library(*extras):
    return rule(
        attrs = _dicts.add(
            ...
            toolchain_transition_attr,
            ...
        ),
        ...
        cfg = scala_version_transition,
        incompatible_use_toolchain_transition = True,
        ...
    )
```


## Toolchains
Standard [toolchain resolution](https://bazel.build/extending/toolchains#toolchain-resolution) procedure determines which toolchain to use for Scala targets.

Toolchain should declare its compatibility with Scala version by using `target_settings` attribute of the `toolchain` rule:

```starlark
toolchain(
    ...
    target_settings = ["@io_bazel_rules_scala_config//:scala_version_3_3_1"],
    ...
)
```

### Cross-build support tiers
`rules_scala` consists of many toolchains implementing various toolchain types.
Their support level for cross-build setup varies.

We can distinguish following tiers:

* No `target_settings` set – not migrated, will work on the default `SCALA_VERSION`; undefined behavior on other versions.
  * (all toolchains not mentioned elsewhere)
* `target_settings` set to the `SCALA_VERSION` – not fully migrated; will work only on the default `SCALA_VERSION` and will fail the toolchain resolution on other versions.
  * (no development in progress)
* Multiple toolchain instances with `target_settings` corresponding to each of `SCALA_VERSIONS` – fully migrated; will work in cross-build setup.
  * [the main Scala toolchain](/scala/BUILD)
  * [Scalafmt](/scala/scalafmt/BUILD)
  * [Scalatest](/testing/testing.bzl)
