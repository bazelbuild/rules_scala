# Cross compilation support

The support for cross-compilation is currently under development.

## Version configuration

`scala_config` creates the repository `@io_bazel_rules_scala_config`.
File created there, `config.bzl`, consists of many variables. In particular:
* `SCALA_VERSION` – representing the default Scala version, e.g. `"3.3.1"`;
* `SCALA_VERSIONS` – representing all configured Scala versions (currently one), e.g. `["3.3.1"]`.
