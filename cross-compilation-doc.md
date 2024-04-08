# Cross compilation support

The support for cross-compilation is currently under development.

## Version configuration

`scala_config` creates the repository `@io_bazel_rules_scala_config`.
File created there, `config.bzl`, consists of many variables. In particular:
* `SCALA_VERSION` – representing the default Scala version, e.g. `"3.3.1"`;
* `SCALA_VERSIONS` – representing all configured Scala versions (currently one), e.g. `["3.3.1"]`.


## Build settings
Configured `SCALA_VERSIONS` correspond to allowed values of [build setting](https://bazel.build/extending/config#user-defined-build-setting).

### `scala_version`
`@io_bazel_rules_scala_config` in its root package defines the following build setting:
```starlark
string_setting(
    name = "scala_version",
    build_setting_default = "3.3.1",
    values = ["3.3.1"],
    visibility = ["//visibility:public"],
)
```
This build setting can be subject of change by [transitions](https://bazel.build/extending/config#user-defined-transitions) (within allowed `values`).

### Config settings
Then for each Scala version we have a [config setting](https://bazel.build/extending/config#build-settings-and-select):
```starlark
config_setting(
    name = "scala_version_3_3_1",
    flag_values = {":scala_version": "3.3.1"},
)
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
TODO


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
  * [the main Scala toolchain](scala/BUILD)
  * [Scalafmt](scala/scalafmt/BUILD)
  * [Scalatest](testing/testing.bzl)
* Multiple toolchain instances with `target_settings` corresponding to each of `SCALA_VERSIONS` – fully migrated; will work in cross-build setup.
