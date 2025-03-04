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

- [scala_library](./docs/scala_library.md)
- [scala_macro_library](./docs/scala_macro_library.md)
- [scala_binary](./docs/scala_binary.md)
- [scala_test](./docs/scala_test.md)
- [scala_repl](./docs/scala_repl.md)
- [scala_library_suite](./docs/scala_library_suite.md)
- [scala_test_suite](./docs/scala_test_suite.md)
- [thrift_library](./docs/thrift_library.md)
- [scala_proto_library](./docs/scala_proto_library.md)
- [scala_toolchain](./docs/scala_toolchain.md)
- [scala_import](./docs/scala_import.md)
- [scala_doc](./docs/scala_doc.md)

## Getting started

[Install Bazel][], preferably using the [Bazelisk][] wrapper. See the
[compatible Bazel versions](#compatible-bazel-versions) section to select a suitable
Bazel version.

[Install Bazel]: https://docs.bazel.build/versions/master/install.html
[Bazelisk]: https://docs.bazel.build/versions/master/install.html

Add the following configuration snippet to your `WORKSPACE` file and update the
release `<VERSION>` and its `<SHA256>` as specified on the [rules_scala releases
page][releases]. This snippet is designed to ensure that users pick up the
correct order of dependencies for `rules_scala`. If you want to override any of
the following dependency versions, make sure to `load()` them before calling
`rules_scala_dependencies()`.

[releases]: https://github.com/bazelbuild/rules_scala/releases

```py
# WORKSPACE
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# See https://github.com/bazelbuild/rules_scala/releases for up to date version
# information, including `<VERSION>` and `<SHA256>` values.
http_archive(
    name = "rules_scala",  # Can be "io_bazel_rules_scala" if you still need it.
    sha256 = "<SHA256>",
    strip_prefix = "rules_scala-<VERSION>",
    url = "https://github.com/bazelbuild/rules_scala/releases/download/<VERSION>/rules_scala-<VERSION>.tar.gz",
)

load("@rules_scala//scala:deps.bzl", "rules_scala_dependencies")

rules_scala_dependencies()

# Only include the next two statements if using
# `--incompatible_enable_proto_toolchain_resolution`.
# See the "Using a precompiled protocol compiler" section below.
load("@platforms//host:extension.bzl", "host_platform_repo")

# Instantiates the `@host_platform` repo to work around:
# - https://github.com/bazelbuild/bazel/issues/22558
host_platform_repo(name = "host_platform")

# This is optional, but still safe to include even when not using
# `--incompatible_enable_proto_toolchain_resolution`.
register_toolchains("@rules_scala//protoc:all")

host_platform_repo(name = "host_platform")

load("@rules_java//java:rules_java_deps.bzl", "rules_java_dependencies")

rules_java_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# If you need a specific `rules_python` version, specify it here.
# Otherwise you may get the version defined in the `com_google_protobuf` repo.
http_archive(
    name = "rules_python",
    sha256 = "2ef40fdcd797e07f0b6abda446d1d84e2d9570d234fddf8fcd2aa262da852d1c",
    strip_prefix = "rules_python-1.2.0",
    url = "https://github.com/bazelbuild/rules_python/releases/download/1.2.0/rules_python-1.2.0.tar.gz",
)

load("@rules_python//python:repositories.bzl", "py_repositories")

py_repositories()

# Note that `rules_java` 8.x suggests loading `protobuf_deps()` after
# `rules_java_dependencies` and before `rules_java_toolchains()`:
# - https://github.com/bazelbuild/rules_java/releases/tag/8.9.0
#
# `rules_java` 7.x also works with this ordering.
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

### Important changes in `rules_scala` v7.0.0 configuration

The above configuration snippet reflects important changes since `rules_scala`
v6.x:

- __`rules_scala` no longer requires the `io_bazel_rules_scala` repository
    name__ unless your `BUILD` files or those of your dependencies require it
    (bazelbuild/rules_scala#1696). You can use the `repo_mapping` attribute of
    `http_archive`, or equivalent Bzlmod mechanisms, to translate `@rules_scala`
    to `@io_bazel_rules_scala` for dependencies. The
    ['@io_bazel_rules_scala_config' is now '@rules_scala_config'](#map) section
    below describes these options in detail. (That section is about
    `@rules_scala_config`, but the same mechanisms apply.)

- __`rules_scala` v7.0.0 introduces a new `scala_toolchains()` API that is
    very different from `rules_scala` 6__. For details on what's changed, see
    the [New 'scala_toolchains()' API for 'WORKSPACE'](#new-toolchains-api)
    section below.

### Loading the `scala_*` rules

Add the following to your `BUILD` files to make the `scala_*` rules available:

```py
load(
    "@rules_scala//scala:scala.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
)
```

### <a id="protoc"></a>Using a precompiled protocol compiler

`rules_scala` now supports
[`--incompatible_enable_proto_toolchain_resolution`][]. When using this flag
with the `MODULE.bazel` or `WORKSPACE` configurations below, `rules_scala` will
use a precompiled protocol compiler binary by default.

[`--incompatible_enable_proto_toolchain_resolution`]: https://bazel.build/reference/command-line-reference#flag--incompatible_enable_proto_toolchain_resolution

__Windows builds now require the precompiled protocol compiler toolchain.__ See
the [Windows MSVC builds of protobuf broken by default](#protoc-msvc) section
below for details.

#### Common setup

To set the flag in your `.bazelrc` file:

```txt
common --incompatible_enable_proto_toolchain_resolution
```

In both `MODULE.bazel` and `WORKSPACE`, add the following statement _before_ any
other toolchain registrations. It's safe to include even when not using
`--incompatible_enable_proto_toolchain_resolution`.

```py
# MODULE.bazel or WORKSPACE
register_toolchains("@rules_scala//protoc:all")
```

#### Temporary required `protobuf` patch

As of `protobuf` v29.3, enabling protocol compiler toolchainization requires
applying [protoc/0001-protobuf-19679-rm-protoc-dep.patch][]. It is the `git
diff` output from the branch used to create protocolbuffers/protobuf#19679.
Without it, there remains a transitive dependency on
`@com_google_protobuf//:protoc`, causing it to recompile even with the
precompiled toolchain registered first.

[protoc/0001-protobuf-19679-rm-protoc-dep.patch]: ./protoc/0001-protobuf-19679-rm-protoc-dep.patch

If and when `protobuf` merges that pull request, or applies an equivalent fix,
this patch will no longer be necessary.

#### Bzlmod setup

Applying the `protobuf` patch requires using [`single_version_override`][],
which also requires that the patch be a regular file in your own repo. In other
words, neither `@rules_scala//protoc:0001-protobuf-19679-rm-protoc-dep.patch`
nor an [`alias`][] to it will work.

[`single_version_override`]: https://bazel.build/rules/lib/globals/module#single_version_override
[`alias`]: https://bazel.build/reference/be/general#alias

Assuming you've copied the patch to a file called `protobuf.patch` in the root
package of your repository, add the following to your `MODULE.bazel`:

```py
# MODULE.bazel

# Required for protocol compiler toolchainization until resolution of
# protocolbuffers/protobuf#19679.
bazel_dep(
    name = "protobuf",
    version = "29.3",
    repo_name = "com_google_protobuf",
)

single_version_override(
    module_name = "protobuf",
    version = "29.3",
    patches = ["//:protobuf.patch"],
    patch_strip = 1,
)
```

#### `WORKSPACE` setup

[`scala/deps.bzl`](./scala/deps.bzl) already applies the `protobuf` patch by
default. If you need to apply it yourself, you can also copy it to your repo as
described in the Bzlmod setup above. Then follow the example in `scala/deps.bzl`
to apply it in your own `http_archive` call.

However, `WORKSPACE` must include the `host_platform_repo` snippet from
[Getting started](#getting-started) to work around bazelbuild/bazel#22558:

```py
# WORKSPACE
load("@platforms//host:extension.bzl", "host_platform_repo")

# Instantiates the `@host_platform` repo to work around:
# - https://github.com/bazelbuild/bazel/issues/22558
host_platform_repo(name = "host_platform")
```

#### More background on protocol compiler toolchainization

- [Proto Toolchainisation Design Doc](
    https://docs.google.com/document/d/1CE6wJHNfKbUPBr7-mmk_0Yo3a4TaqcTPE0OWNuQkhPs/edit)

- [bazelbuild/bazel#7095: Protobuf repo recompilation sensitivity](
    https://github.com/bazelbuild/bazel/issues/7095)

- [bazelbuild/rules_proto#179: Implement proto toolchainisation](
    https://github.com/bazelbuild/rules_proto/issues/179)

- [rules_proto 6.0.0 release notes mentioning Protobuf Toolchainization](
    https://github.com/bazelbuild/rules_proto/releases/tag/6.0.0)

### Persistent workers

To run with a persistent worker (much faster), add the following to
your `.bazelrc` file:

```txt
build --strategy=Scalac=worker
build --worker_sandboxing
```

## Coverage support

To produce a combined coverage report:

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

The [Getting started](#getting-started) section illustrates how to select the
default Scala version and configure its dependencies.

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

| Bazel/Dependency |  `rules_scala` 7.x |
| :-: |  :-: |
| Bazel versions using Bzlmod<br/>(Coming soon! See bazelbuild/rules_scala#1482.) | 7.5.0, 8.x |
| Bazel versions using `WORKSPACE` | 6.5.0, 7.5.0, 8.x<br/>(see the [notes on 6.5.0 compatibility](#6.5.0)) |
| `protobuf` |  v29.3 |
| `abseil-cpp` | 20250127.0 |
| `rules_java` | 8.9.0 |
| `ScalaPB` | 1.0.0-alpha.1 |

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
to Bazel 8 and Bzlmod.__ To facilitate a gradual migration, it is compatible
with both Bazel 7 and Bazel 8, and both `WORKSPACE` and Bzlmod. It remains
compatible with Bazel 6.5.0 builds using `WORKSPACE` for the time being, but
Bazel 6 is no longer officially supported.

`rules_java` 7.x contains the following breaking changes when upgrading from
`rules_scala` 6.x.

### <a id="new-toolchains-api"></a>New `scala_toolchains()` API for `WORKSPACE`

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

Replace toolchain configurations like the following:

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

# See the `WORKSPACE` configuration snippet from the "Getting started" section
# above for other dependency declarations.

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

See the [`scala_toolchains()`](./scala/toolchains.bzl) docstring for the
parameter list, which is almost in complete correspondence with parameters from
the previous macros. The `WORKSPACE` files in this repository also provide many
examples.

### Replacing toolchain registration macros in `WORKSPACE`

Almost all `rules_scala` toolchains are automatically configured and registered by
`scala_toolchains()` and `scala_register_toolchains()`. There are two toolchain
macro replacements that require special handling.

The first is replacing `scala_proto_register_enable_all_options_toolchain()`
with the following `scala_toolchains()` parameters:

```py
scala_toolchains(
    scala_proto = True,
    scala_proto_enable_all_options = True,
)
```

The other is replacing `scala_register_unused_deps_toolchains()` with an
explicit `register_toolchains()` call:

```py
register_toolchains(
    "@rules_scala//scala:unused_dependency_checker_error_toolchain",
)
```

In `WORKSPACE`, this `register_toolchains()` call must come before calling
`scala_register_toolchains()` to ensure this toolchain takes precedence. The
same exact call will also work in `MODULE.bazel`.

### Bzlmod configuration (coming soon!)

The upcoming Bzlmod implementation will funnel through the `scala_toolchains()`
macro as well, ensuring maximum compatibility with `WORKSPACE` configurations.
The equivalent Bzlmod configuration for the `scala_toolchains()` configuration
above would be:

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

The module extensions will call `scala_config()` and `scala_toolchains()`
respectively. The `MODULE.bazel` file for `rules_scala` declares its own
dependencies via `bazel_dep()`, allowing Bazel to resolve versions according to
the main repository/root module configuration. It also calls
[`register_toolchains()`][reg_tool], so you don't have to (unless you want to
register a specific toolchain to resolve first).

[reg_tool]: https://bazel.build/rules/lib/globals/module#register_toolchains

The `MODULE.bazel` files in this repository will also provide many examples
(when they land per bazelbuild/rules_scala#1482).

#### Copy `register_toolchains()` calls from `WORKSPACE` to `MODULE.bazel`

The `MODULE.bazel` file from `rules_scala` will automatically call
`register_toolchains()` for toolchains configured via its `scala_deps` module
extension. However, you must register explicitly in your `MODULE.bazel` file any
toolchains that you want to take precedence over the toolchains configured by
`scala_deps`. This includes any [`scala_toolchain`](./docs/scala_toolchain.md)
targets defined in your project, or optional `rules_scala` toolchains like the
dependency checker error toolchain from above:

```py
register_toolchains(
    "@rules_scala//scala:unused_dependency_checker_error_toolchain",
)
```

### <a id="map"></a>`@io_bazel_rules_scala_config` is now `@rules_scala_config`

Since `@io_bazel_rules_scala` is no longer hardcoded in `rules_scala` internals,
we've shortened `@io_bazel_rules_scala_config` to `@rules_scala_config`. This
shouldn't affect most users, but it may break some builds using
`@io_bazel_rules_scala_config` to define custom [cross-compilation targets](
./docs/cross-compilation.md).

If you can't fix uses of `@io_bazel_rules_scala_config` in your own project
immediately, or have dependencies that need it, there are options.
Use one of the following mechanisms to override it with `@rules_scala_config`.

The same mechanisms also apply if you need to translate `@rules_scala` to
`@io_bazel_rules_scala` for your dependencies.

#### Bzlmod

You can remap `@rules_scala_config` via [`use_repo()`] if you need it in your
own project:

[`use_repo()`]: https://bazel.build/rules/lib/globals/module#use_repo

```py
scala_config = use_extension(
    "@rules_scala//scala/extensions:config.bzl",
    "scala_config",
)

use_repo(scala_config, io_bazel_rules_scala_config = "rules_scala_config")
```

For [`bazel_dep()`][] dependencies, use [`override_repo()`][] to
override `@io_bazel_rules_scala_config` with `@rules_scala_config`:

```py
bazel_dep(name = "foo", version = "1.0.0")

foo_ext = use_extension("@foo//:ext.bzl", "foo_ext")
override_repo(foo_ext, io_bazel_rules_scala_config = "rules_scala_config")
```

[`bazel_dep()`]: https://bazel.build/rules/lib/globals/module#bazel_dep
[`override_repo()`]: https://bazel.build/rules/lib/globals/module#override_repo

For [`archive_override()`][] and [`git_override()`][] dependencies, use the
`repo_mapping` attribute passed through to the underlying [`http_archive()`][]
and [`git_repository()`][] rules:

```py
archive_override(
    ...
    repo_mapping = {
        "@io_bazel_rules_scala_config": "@rules_scala_config",
    }
    ...
)
```

[`archive_override()`]: https://bazel.build/rules/lib/globals/module#archive_override
[`git_override()`]: https://bazel.build/rules/lib/globals/module#git_override
[`http_archive()`]: https://bazel.build/rules/lib/repo/http#http_archive-repo_mapping
[`git_repository()`]: https://bazel.build/rules/lib/repo/git#git_repository-repo_mapping

#### `WORKSPACE`

Use the `repo_mapping` attribute of [`http_archive()`][] or
[`git_repository()`][]:

```py
http_archive(
    ...
    repo_mapping = {
        "@io_bazel_rules_scala_config": "@rules_scala_config",
    }
    ...
)
```

### <a id="protoc-msvc"></a>Windows MSVC builds of `protobuf` broken by default

MSVC builds of recent `protobuf` versions started failing, as first noted in
bazelbuild/rules_scala#1710. On top of that, `protobuf` is planning to stop
supporting Bazel + MSVC builds per:

- [protocolbuffers/protobuf#12947: src build on windows not working](
    https://github.com/protocolbuffers/protobuf/issues/12947)

- [protobuf.dev News Announcements for Version 30.x:Poison MSVC + Bazel](
    https://protobuf.dev/news/v30/#poison-msvc--bazel)

- [protocolbuffers/protobuf#20085: Breaking Change: Dropping support for
    Bazel+MSVC](https://github.com/protocolbuffers/protobuf/issues/20085)

Enable [protocol compiler toolchainization](#protoc) to fix broken Windows
builds by avoiding `@com_google_protobuf//:protoc` recompilation.

### Embedded resource paths no longer begin with `external/<repo_name>`

[Any program compiled with an external repo asset in its 'resources' attribute
will need to strip the 'external/' and repo name components from its
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

### Builtin repositories no longer visible by default under Bzlmod

Under Bzlmod, repos are only visible to the module extension that creates them,
unless the `MODULE.bazel` file brings them into scope with
[`use_repo()`](https://bazel.build/rules/lib/globals/module#use_repo). This can
lead to errors like those from the following example, which [originally called
`setup_scala_toolchain()` under Bzlmod](
https://github.com/michalbogacz/scala-bazel-monorepo/blob/17f0890a4345529e09b9ce83bcb2e3d15687c522/BUILD.bazel):

```py
load("@rules_scala//scala:scala.bzl", "setup_scala_toolchain")

setup_scala_toolchain(
    name = "custom_scala_toolchain",
    scalacopts = [
        "-Wunused:all",
    ],
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "warn",
)
```

`setup_scala_toolchains` is a macro that can take user specified classpath
targets as described in [docs/scala_toolchain.md](./docs/scala_toolchain.md).
Without explicit `*_classpath` or `*_deps` arguments, `setup_scala_toolchain()`
defaults to using dependency repositories generated by `rules_scala` itself.
This worked under `WORKSPACE`, but breaks under Bzlmod, because the builtin
toolchain dependency repos are no longer in the project's scope by default:

```txt
ERROR: no such package
    '@@[unknown repo 'org_scala_sbt_compiler_interface_3_3_5'
        requested from @@]//':
    The repository '@@[unknown repo 'org_scala_sbt_compiler_interface_3_3_5'
        requested from @@]' could not be resolved:
    No repository visible as '@org_scala_sbt_compiler_interface_3_3_5'
```

In this case, where the toolchain only sets different compiler options, the best
fix is to [use `scala_toolchain` directly instead][scala_tc_direct]. Its
underlying `BUILD` rule uses builtin toolchain dependencies via existing targets
visible within `rules_scala`, without forcing users to import them:

[scala_tc_direct]: https://github.com/michalbogacz/scala-bazel-monorepo/blob/2cac860f386dcaa1c3be56cd25a84b247d335743/BUILD.bazel

```py
load("@rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "custom_scala_toolchain_impl",
    scalacopts = [
        "-Ywarn-unused",
    ],
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "warn",
)

toolchain(
    name = "custom_scala_toolchain",
    toolchain = ":custom_scala_toolchain_impl",
    toolchain_type = "@rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)
```

A big part of the Bzlmodification work involved enabling `rules_scala` to
generate and register toolchains _without_ forcing users to bring their
dependencies into scope. However, another way to fix this specific problem is to
call `use_repo` for every builtin repository needed by the
`setup_scala_toolchain()` call.

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

__`rules_scala` 7.x officially drops support for Bazel 6.5.0.__ Bzlmod builds
with Bazel 6.5.0 won't work at all because [Bazel 6.5.0 doesn't support
'use_repo_rule']( https://bazel.build/versions/6.5.0/rules/lib/globals), which
['rules_jvm_external' >= 6.3 requires](
https://github.com/bazelbuild/rules_scala/issues/1482#issuecomment-2515496234).

At the moment, `WORKSPACE` builds mostly continue to work with Bazel 6.5.0, but
not out of the box, and may break at any time. You will have to choose one of
the following approaches to resolve `protobuf` compatibility issues.

First, you may choose to use protocol compiler toolchainization. See the [Using
a precompiled protocol compiler](#protoc) section for details.

Otherwise, per bazelbuild/rules_scala#1647, you must add the following flags to
`.bazelrc`, required by the newer `abseil-cpp` version used by `protobuf`:

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

If you have another dependency that requires an earlier `protobuf` version, use
the following maximum dependency versions:

| Dependency | Max Bazel 6.5.0 compatible version | Reason |
| :-: | :-: | :- |
| `protobuf` | v25.6 | `ScalaPB` doesn't support `protobuf` v26 or v27. |
| `abseil-cpp` | 20240722.0 | Latest that works with `protobuf` v25; requires C++ compiler flags. |
| `rules_java` | 7.12.4 | 8.x requires `protobuf` v27 and later. |
| `rules_cc` | 0.0.9 | 0.0.10 requires Bazel 7 to define `CcSharedLibraryHintInfo`.<br/>0.0.13 requires at least `protobuf` v27.0. |
| `ScalaPB` | 0.11.17<br/>(0.9.8 for Scala 2.11) | Supports `protobuf` < v26. |

### `scala_proto` not supported for Scala 2.11

[ScalaPB 0.9.8](https://github.com/scalapb/ScalaPB/releases/tag/v0.9.8), the
last version compatible with Scala 2.11, does not support `protobuf` >= v26.
Since `rules_scala` now depends on a more recent `protobuf` version, we had to
remove the Scala 2.11 test cases.

Building `scala_proto` for Scala 2.11 requires [building with Bazel 6.5.0
under `WORKSPACE`](#6.5.0), with the maximum dependency versions specified in
that section. While this may continue to work for some time, it is not
officially supported.

### Bazel module compatibility levels

`rules_scala` 7.0.0 will set the
[`compatibility_level`](https://bazel.build/external/module#compatibility_level)
value for its [`module()`](https://bazel.build/rules/lib/globals/module)
directive. The `compatibility_level` for `rules_scala` will track major version
numbers (per [semantic versioning](https://semver.org/)), and this `README` will
clearly document the reason for the level bump. `compatibility_level` mismatches
in the module graph will cause module resolution to fail, signaling the presence
of known breaking changes.

The concept of proper `compatibility_level` usage is still up for discussion in
bazelbuild/bazel#24302. However, the policy above favors forcing module
resolution to fail, rather than allowing a later execution step to fail with a
potentially confusing error message. If a version bump may break builds for any
known reason, we will explain why up front instead of waiting for users to be
surprised.

[A comment from #1647 illustrates how 'rules_erlang' fails due to
'compatibility_level' conflicts][erlang]. The ['rules_erlang' 3.0.0 release
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
