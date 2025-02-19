# Scala Rules for Bazel

[![Build status](https://badge.buildkite.com/90ce5244556df74db805a3c24a703fb87458396f9e1ddd687e.svg?branch=master)](https://buildkite.com/bazel/scala-rules-scala-postsubmit)

## Where to get help

- [#scala @ Bazel Slack](https://bazelbuild.slack.com/archives/CDCKJ2KFZ)
- [Google group](https://groups.google.com/u/1/g/bazel-scala)
- [Gitter chat](https://gitter.im/bazelbuild_rules_scala/Lobby)

## Overview

[Bazel](https://bazel.build/) is a tool for building and testing software and can handle large,
multi-language projects at scale.

This project defines core build rules for [Scala](https://www.scala-lang.org/) that can be used to build, test, and package Scala projects.

## Rules

- [scala_library](docs/scala_library.md)
- [scala_macro_library](docs/scala_macro_library.md)
- [scala_binary](docs/scala_binary.md)
- [scala_test](docs/scala_test.md)
- [scala_repl](docs/scala_repl.md)
- [scala_library_suite](docs/scala_library_suite.md)
- [scala_test_suite](docs/scala_test_suite.md)
- [thrift_library](docs/thrift_library.md)
- [scala_proto_library](docs/scala_proto_library.md)
- [scala_toolchain](docs/scala_toolchain.md)
- [scala_import](docs/scala_import.md)
- [scala_doc](docs/scala_doc.md)

## Getting started

[Install Bazel][], preferably using the [Bazelisk][] wrapper. See the
[compatbile Bazel versions](#compatible-bazel-versions) section to select a suitable
Bazel version.

[Install Bazel]: https://docs.bazel.build/versions/master/install.html
[Bazelisk]: https://docs.bazel.build/versions/master/install.html

Add the following stanza to your `WORKSPACE` file and update versions with their
sha256s if needed. This stanza is designed to ensure that users pick up the
correct order of dependencies for `rules_scala`. If you want to override any of
the following dependency versions, make sure to `load()` them before calling
`rules_scala_dependencies()`.

As of version 7.0.0, __`rules_scala` no longer requires the
`io_bazel_rules_scala` repository name__ unless your `BUILD` files or those of
your dependencies require it (bazelbuild/rules_scala#1696). In that case, the
old name will still work when using `http_archive`.

```py
# WORKSPACE
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# See https://github.com/bazelbuild/rules_scala/releases for up to date version
# information, including `<SHASUM>` values.
http_archive(
    name = "rules_scala",
    sha256 = "<SHASUM>",
    strip_prefix = "rules_scala-7.0.0",
    url = "https://github.com/bazelbuild/rules_scala/releases/download/7.0.0/rules_scala-7.0.0.tar.gz",
)

load("@rules_scala//scala:deps.bzl", "rules_scala_dependencies")

rules_scala_dependencies()

load("@rules_java//java:rules_java_deps.bzl", "rules_java_dependencies")

rules_java_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# If you need a specific `rules_python` version, specify it here.
# Otherwise you may get the version defined in the `com_google_protobuf` repo.
# We use 0.38.0 to maintain compatibility with Bazel 6.5.0; this will change in
# the next release.
http_archive(
    name = "rules_python",
    sha256 = "ca2671529884e3ecb5b79d6a5608c7373a82078c3553b1fa53206e6b9dddab34",
    strip_prefix = "rules_python-0.38.0",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.38.0/rules_python-0.38.0.tar.gz",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

# Note that `rules_java` suggests loading `protobuf_deps()` after
# `rules_java_dependencies` and before `rules_java_toolchains()`:
# - https://github.com/bazelbuild/rules_java/releases/tag/8.9.0
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

load("@rules_java//java:repositories.bzl", "rules_java_toolchains")

rules_java_toolchains()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies")

rules_proto_dependencies()

load("@rules_proto//proto:setup.bzl", "rules_proto_setup")

rules_proto_setup()

load("@rules_proto//proto:toolchains.bzl", "rules_proto_toolchains")

rules_proto_toolchains()

load("@rules_scala//:scala_config.bzl", "scala_config")

# Stores the selected Scala version and other configuration parameters.
#
# 2.12 is the default version. Use other versions by passing them explicitly:
#
#   scala_config(scala_version = "2.13.16")
#
# You may define your own custom toolchain using Maven artifact dependencies
# configured by your `WORKSPACE` file, imported using external loader like
# https://github.com/bazelbuild/rules_jvm_external.
scala_config()

load(
    "@rules_scala//scala:toolchains.bzl",
    "scala_register_toolchains",
    "scala_toolchains",
)

# Defines a default toolchain repo for the configured Scala version that
# loads Maven deps like the Scala compiler and standard libs. On production
# projects, you may consider defining a custom toolchain to use your project's
# required dependencies instead.
#
# Optional builtin rules_scala toolchains may be configured by setting
# parameters as documented in the `scala_toolchains()` docstring.
scala_toolchains(
    scalatest = True,
)

scala_register_toolchains()
```

This will load the `rules_scala` repository at the commit sha
`rules_scala_version` into your Bazel project and register a [scala_toolchain](docs/scala_toolchain.md) at the default Scala version (2.12.20)

Then in your BUILD file just add the following so the rules will be available:

```py
load(
    "@rules_scala//scala:scala.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
)
```

You may wish to have these rules loaded by default using bazel's prelude. You can add the above to the file `tools/build_rules/prelude_bazel` in your repo (don't forget to have a, possibly empty, BUILD file there) and then it will be automatically prepended to every BUILD file in the workspace.

To run with a persistent worker (much faster), you need to add

```txt
build --strategy=Scalac=worker
build --worker_sandboxing
```

to your command line, or to enable by default for building/testing add it to
your `.bazelrc`.

## Coverage support

It will produce several .dat files with results for your targets.

You can also add more options to receive a combined coverage report:

```txt
bazel coverage \
  --combined_report=lcov \
  --coverage_report_generator="@bazel_tools//tools/test/CoverageOutputGenerator/java/com/google/devtools/coverageoutputgenerator:Main" \
  //...
```

This should produce a single `bazel-out/_coverage/_coverage_report.dat` from all coverage files that are generated.

You can extract information from your coverage reports with
[`lcov`](https://github.com/linux-test-project/lcov):

```txt
# For a summary:
lcov --summary your-coverage-report.dat

# For details:
lcov --list your-coverage-report.dat
```

If you prefer an HTML report, then you can use `genhtml` provided also by the `lcov` package.

Coverage support has been only tested with [ScalaTest](http://www.scalatest.org/).

Please check [coverage.md](docs/coverage.md) for more details on coverage support.

## Selecting the Scala version

### With builtin toolchains

`rules_scala` supports the last two released minor versions for each of Scala 2.11, 2.12, 2.13.
Previous minor versions may work but are supported only on a best effort basis.

First select the default Scala version by calling `scala_config(scala_version = "2.xx.xx")` and configure
dependencies by calling [scala_toolchains()](docs/scala_toolchain.md) and `scala_register_toolchains()`:

```py
# WORKSPACE
load("@rules_scala//:scala_config.bzl", "scala_config")
scala_config(scala_version = "2.13.16")

load(
    "@rules_scala//scala:toolchains.bzl",
    "scala_register_toolchains",
    "scala_toolchains",
)

scala_toolchains()

scala_register_toolchains()
```

### With custom toolchains

You can define your own custom [scala_toolchain](docs/scala_toolchain.md) by
calling `setup_scala_toolchain()` with dependencies that you specify.

Note: Toolchains are a more flexible way to configure dependencies, so you should prefer that way.
Please also note, that the `overriden_artifacts` parameter is likely to be removed in the future.

### Multiple versions (cross-compilation)

`rules_scala` supports configuring multiple Scala versions and offers target-level control of which one to use.

Please check [cross-compilation.md](docs/cross-compilation.md) for more details on cross-compilation support.

## Compatible Bazel versions

Bazel compatibility is tied directly to the versions of `protobuf` required by
Bazel and `rules_java`, and their compatibility with [scalabp/ScalaPB](
https://github.com/scalapb/ScalaPB) Maven artifacts. For extensive analysis,
see bazelbuild/rules_scala#1647.

The Bazel versions and dependency versions in the table below represent the
maximum available at the time of writing.

- For the actual versions used by `rules_scala`, see
    [scala/deps.bzl](scala/deps.bzl).

- See [the configuration file][ci-config] for the exact Bazel versions verified
    with the continuous-integration builds.

[ci-config]: ./.bazelci/presubmit.yml

| Bazel/Dependency | `rules_scala` 7.x | `rules_scala` 8.x<br/>(Coming soon! See bazelbuild/rules_scala#1482 and bazelbuild/rules_scala#1652.) |
| :-: | :-: | :-: |
| Bazel versions using Bzlmod<br/>(Coming soon! See bazelbuild/rules_scala#1482.) | 6.5.0, 7.5.0 | 7.5.0, 8.x |
| Bazel versions using `WORKSPACE` | 6.5.0, 7.5.0 | 6.5.0, 7.5.0, 8.x<br/>(see the [notes on 6.5.0 compatibility](#6.5.0)) |
| `protobuf` | v21.7<br/>(can support up to v25.5) | v29.3 |
| `abseil-cpp` | 20220623.1 | 20250127.0 |
| `rules_java` | 7.12.4 | 8.x |
| `ScalaPB` | 0.11.17<br/>(0.9.8 for Scala 2.11) | 1.0.0-alpha.1 |

## Usage with [bazel-deps](https://github.com/johnynek/bazel-deps)

Bazel-deps allows you to generate bazel dependencies transitively for maven artifacts. Generally we don't want bazel-deps to fetch
scala artifacts from maven but instead use the ones we get from calling `scala_repositories`. The artifacts can be overridden in the
dependencies file used by bazel-deps:

```yaml
replacements:
  org.scala-lang:
    scala-library:
      lang: scala/unmangled
      target: "@io_bazel_rules_scala_scala_library//:io_bazel_rules_scala_scala_library"
    scala-reflect:
      lang: scala/unmangled
      target: "@io_bazel_rules_scala_scala_reflect//:io_bazel_rules_scala_scala_reflect"
    scala-compiler:
      lang: scala/unmangled
      target: "@io_bazel_rules_scala_scala_compiler//:io_bazel_rules_scala_scala_compiler"

  org.scala-lang.modules:
    scala-parser-combinators:
      lang: scala
      target:
        "@io_bazel_rules_scala_scala_parser_combinators//:io_bazel_rules_scala_scala_parser_combinators"
    scala-xml:
      lang: scala
      target:
        "@io_bazel_rules_scala_scala_xml//:io_bazel_rules_scala_scala_xml"
```

## Publishing to Maven repository

See [Publish your Scala Libraries to a Maven Repository](
docs/publish_to_maven.md).

## Dependency Tracking

`rules_scala` supports multiple dependency modes including strict and unused dependency tracking. See
[Dependency Tracking](docs/dependency-tracking.md) for more info.

## Advanced configurable rules

To make the ruleset more flexible and configurable, we introduce a phase architecture. By using a phase architecture, where rule implementations are defined as a list of phases that are executed sequentially, functionality can easily be added (or modified) by adding (or swapping) phases.

Phases provide 3 major benefits:

- Consumers are able to configure the rules to their specific use cases by
    defining new phases within their workspace without impacting other consumers.
- Contributors are able to implement new functionalities by creating additional
    default phases.
- Phases give us more clear idea what steps are shared across rules.

See [Customizable Phase](docs/customizable_phase.md) for more info.

### Phase extensions

- [Scala Format](docs/phase_scalafmt.md)

## Building from source

Build main sources only:

```txt
bazel build //src/...
```

Run all smaller tests:

```txt
bazel test //test/...
```

To run the full test suite:

```txt
bash test_all.sh
```

Note: __`bazel test //...` will not work__ since we have a sub-folder on the
root folder which is meant to be used in a failure scenario in the integration
tests. Similarly, to only build you should use `bazel build //src/...` due to
that folder.

## Breaking changes in `rules_scala` 7.x

__The main objective of `rules_scala` 7.x is to enable existing users to migrate
to Bazel 7 and Bzlmod.__ To facilitate a gradual migration, it remains
compatible with both `WORKSPACE` and Bzlmod. However, it contains the following
breaking changes when upgrading from `rules_scala` 6.x.

### New `scala_toolchains()` API for `WORKSPACE`

`rules_scala` 7.0.0 replaces existing `*_repositories()` and `*_toolchains()`
macros with the combination of `rules_scala_dependencies()`,
`scala_toolchains()`, and `scala_register_toolchains()`.

These macros no longer exist:

- `jmh_repositories()`
- `junit_repositories()`
- `junit_toolchain()`
- `rules_scala_setup()`
- `rules_scala_toolchain_deps_repositories()`
- `scala_proto_default_repositories()`
- `scala_proto_register_enable_all_options_toolchain()`
- `scala_proto_register_toolchains()`
- `scala_proto_repositories()`
- `scala_register_unused_deps_toolchains()`
- `scala_repositories()`
- `scalafmt_default_config()`
- `scalafmt_repositories()`
- `scalatest_repositories()`
- `scalatest_toolchain()`
- `specs2_junit_repositories()`
- `specs2_repositories()`
- `specs2_version()`
- `twitter_scrooge()`

Replace toolchain stanzas like the following:

```py
load(
    "@rules_scala//scala:scala.bzl",
    "rules_scala_setup",
    "rules_scala_toolchain_deps_repositories",
)

rules_scala_setup()

rules_scala_toolchain_deps_repositories(fetch_sources = True)

# Other dependency declarations...

load("@rules_scala//:scala_config.bzl", "scala_config")

scala_config(scala_version = "2.13.16")

load(
    "//testing:scalatest.bzl",
    "scalatest_repositories",
    "scalatest_toolchain",
)

scalatest_repositories()

scalatest_toolchain()

load(
    "//scala/scalafmt:scalafmt_repositories.bzl",
    "scalafmt_default_config",
    "scalafmt_repositories",
)

scalafmt_default_config()

scalafmt_repositories()
```

with calls to `rules_scala_dependencies()`, `scala_toolchains()` (with the
appropriate parameters set), and `scala_register_toolchains()`:

```py
load("@rules_scala//scala:deps.bzl", "rules_scala_dependencies")

rules_scala_dependencies()

# See the `WORKSPACE` stanza from the "Getting started" section above
# for other dependency declarations.

load("@rules_scala//:scala_config.bzl", "scala_config")

scala_config(scala_version = "2.13.16")

load(
    "@rules_scala//scala:toolchains.bzl",
    "scala_register_toolchains",
    "scala_toolchains",
)

# Note that `rules_scala` toolchain repos are _always_ configured.
scala_toolchains(
    scalafmt = True,
    scalatest = True,
)

scala_register_toolchains()
```

See the [`scala_toolchains()` docstring](./scala/toolchains.bzl) for the
parameter list, which is almost in complete correspondence with parameters from
the previous macros. The `WORKSPACE` files in this repository also provide many
examples.

### Replacing toolchain registration macros

`MODULE.bazel` not only doesn't allow `load()` statements, and therefore macros,
but _all `register_toolchains()` calls_ __must__ _appear in `MODULE.bazel`_.

Almost all `rules_scala` toolchains are automatically configured and registered by
`scala_toolchains()` and `scala_register_toolchains()`. There are two exceptions.

The first exception is `scala_proto_register_enable_all_options_toolchain()`.
Replace this macro with:

```py
scala_toolchains(
    scala_proto = True,
    scala_proto_enable_all_options = True,
)
```

The other exception is `scala_register_unused_deps_toolchains()`. Replace this
macro with:

```py
register_toolchains(
    "@rules_scala//scala:unused_dependency_checker_error_toolchain",
)
```

In `WORKSPACE`, this must come before calling `scala_register_toolchains()` to
ensure this toolchain takes precedence. The same exact call will also work in
`MODULE.bazel`.

`scala_register_toolchains()` should remain in `WORKSPACE`, but there's no
equivalent for `MODULE.bazel`. The `MODULE.bazel` file from `rules_scala` will
automatically call `register_toolchains()` for toolchains configured via its
module extension, so you don't have to.

### Bzlmod configuration (coming soon!)

The upcoming Bzlmod implementation will funnel through the `scala_toolchains()`
macro as well, ensuring maximum compatibility with `WORKSPACE` configurations.
The equivalent Bzlmod stanza for the `scala_toolchains()` stanza above would be
the following.

```py
bazel_dep(name = "rules_scala", version = "7.0.0")

scala_config = use_extension(
    "@rules_scala//scala/extensions:config.bzl",
    "scala_config",
)

scala_config.settings(scala_version = "2.13.16")

scala_deps = use_extension(
    "@rules_scala//scala/extensions:deps.bzl",
    "scala_deps",
)

scala_deps.toolchains(
    scalafmt = True,
    scalatest = True,
)
```

The module extensions will call `scala_config()` and `scala_toolchains()` in
their implementation. The `MODULE.bazel` file for `rules_scala` declares its own
dependencies via `bazel_dep()`, allowing Bazel to resolve versions according to
the main repository/root module configuration. It also calls
[`register_toolchains()`][reg_tool], so you don't have to (unless you want to
register a specific toolchain to resolve first).

[reg_tool]: https://bazel.build/rules/lib/globals/module#register_toolchains

The `MODULE.bazel` files in this repository will also provide many examples
(when they land per bazelbuild/rules_scala#1482).

### Embedded resource paths no longer begin with `external/<repo_name>`

[Any program compiled with an external repo asset in its `resources` attribute
will need to strip the `external/` and repo name components from its
path][ext-path]. For example, the path for `resources =
["@some_external_repo//:resource.txt"]` would change thus:

[ext-path]: https://github.com/bazelbuild/rules_scala/pull/1621#issuecomment-2417506589

- Before: `external/some_external_repo/resource.txt`
- After: `resource.txt`

This avoids encoding repo names or any other Bazel system knowledge in the
compiled artifacts. This is especially important under Bzlmod, because the
generated path would otherwise contain [the _canonical_ repo name,  upon which
users should never
depend](https://bazel.build/external/module#repository_names_and_strict_deps).

### Update `@bazel_tools//tools/jdk` targets to `@rules_java//toolchains` targets

Per bazelbuild/rules_scala#1660, `rules_java` 7.10.0 and later precipitate the
need to replace `@bazel_tools//tools/jdk` targets with corresponding
`@rules_java//toolchains` targets. Fix any targets broken by this `rules_java`
upgrade by doing a global search and replace.

However, `@bazel_tools//tools/jdk:toolchain_type` dependencies must remain for
now, as there's not yet a corresponding [`toolchain_type()`](
https://bazel.build/versions/6.1.0/reference/be/platform#toolchain_type) target
in `@rules_java`.

## Breaking changes coming in `rules_scala` 8.x

__The main objective of 8.x will be to enable existing users to migrate to Bazel
8 and Bzlmod.__ To facilitate a gradual migration, it will remain compatible
with both `WORKSPACE` and Bzlmod. However, it will contain the following
breaking changes when upgrading from `rules_scala` 7.x.

### Replace some `$(location)` calls with `$(rootpath)` for Bazel 8

This isn't actually a `rules_scala` breakage, but a Bazel 8 breakage encountered
while preparing `rules_scala` for Bazel 8 in bazelbuild/rules_scala#1652.
bazelbuild/bazel#25198 describes how the semantics of some instances of
`$(location)` changed, and how changing these particular instances to
`$(rootpath)` fixed them.

The good news is that replacing such instances `$(location)` with `$(rootpath)`
is backwards compatible to Bazel 6.5.0 and 7.5.0. Updating them now will ensure
future compatibility.

### <a id="6.5.0"></a>Limited Bazel 6.5.0 compatibility

`rules_scala` 8.0.0 will not support Bzlmod with Bazel 6.5.0 because
[Bazel 6.5.0 doesn't support `use_repo_rule`](
https://bazel.build/versions/6.5.0/rules/lib/globals), which
[`rules_jvm_external` >= 6.3 requires](
https://github.com/bazelbuild/rules_scala/issues/1482#issuecomment-2515496234).

`WORKSPACE` builds will continue to work with Bazel 6.5.0, but not out of the
box. Per #1647, using Bazel 6.5.0 with `rules_scala` 8.x will require adding the
following flags to `.bazelrc`, required by the newer `abseil-cpp` version used
by `protobuf`:

```txt
common --enable_platform_specific_config

common:linux --cxxopt=-std=c++17
common:linux --host_cxxopt=-std=c++17
common:macos --cxxopt=-std=c++17
common:macos --host_cxxopt=-std=c++17
common:windows --cxxopt=/std=c++17
common:windows --host_cxxopt=/std=c++17
```

Note that this example uses `common:` config settings instead of `build:`. This
seems to prevent invalidating the action cache between `bazel` runs, which
improves performance.

### Bazel module compatibility levels between 7.0.0 and 8.0.0

`rules_scala` 7.0.0 and 8.0.0 will have different
[`compatibility_level`](https://bazel.build/external/module#compatibility_level)
values for their [`module()`](https://bazel.build/rules/lib/globals/module)
directives. This is due to the gap in supported `protobuf` versions documented
in #1647 (between v25.5 and v28).

This will ensure any users attempting to mismatch `protobuf` and `rules_scala`
versions will break during module resolution, rather than during a later
execution step. (Though, as described in #1647, there are now measures in place
to cause the build to crash during a mismatch instead of hanging.)

The concept of proper `compatibility_level` usage is still up for discussion in
bazelbuild/bazel#24302. The `rules_scala` implementation will track semantic
versioning major version numbers, and clearly document the reason for the level
bump. If a version bump may break builds for any known reason, we should explain
why up front instead of waiting for users to be surprised.

[A comment from #1647 illustrates how `rules_erlang` fails due to
`compatibility_level` conflicts][erlang]. The [`rules_erlang` 3.0.0 release
notes](https://github.com/rabbitmq/rules_erlang/releases/tag/3.0.0) describe the
breaking changes. This seems like a reasonable model to follow.

[erlang]: https://github.com/bazelbuild/rules_scala/issues/1647#issuecomment-2486777859

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more info.

## Adopters

Here's a (non-exhaustive) list of companies that use `rules_scala` in production. Don't see yours? [You can add it in a PR](https://github.com/bazelbuild/rules_scala/edit/master/README.md)!

- [Ascend](https://ascend.io/)
- [Canva](https://www.canva.com/)
- [Domino Data Lab](https://www.dominodatalab.com/)
- [Etsy](https://www.etsy.com/)
- [Gemini](https://gemini.com/)
- [Grand Rounds](http://grandrounds.com/)
- [Kitty Hawk](https://kittyhawk.aero/)
- [Meetup](https://meetup.com/)
- [Spotify](https://www.spotify.com/)
- [Stripe](https://stripe.com/)
- [Tally](https://www.meettally.com/)
- [Twitter](https://twitter.com/)
- [VirtusLab](https://virtuslab.com/)
- [VSCO](https://vsco.co)
- [Wix](https://www.wix.com/)
- [Yobi](https://www.yobi.ai/)
