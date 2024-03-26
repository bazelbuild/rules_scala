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
TODO

### From config setting
TODO