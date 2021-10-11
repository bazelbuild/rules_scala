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

* [scala_library](docs/scala_library.md)
* [scala_macro_library](docs/scala_macro_library.md)
* [scala_binary](docs/scala_binary.md)
* [scala_test](docs/scala_test.md)
* [scala_repl](docs/scala_repl.md)
* [scala_library_suite](docs/scala_library_suite.md)
* [scala_test_suite](docs/scala_test_suite.md)
* [thrift_library](docs/thrift_library.md)
* [scala_proto_library](docs/scala_proto_library.md)
* [scala_toolchain](docs/scala_toolchain.md)
* [scala_import](docs/scala_import.md)
* [scala_doc](docs/scala_doc.md)

## Getting started

1. [Install Bazel](https://docs.bazel.build/versions/master/install.html), 
see the [compatibility table](#bazel-compatible-versions).
2. Add the following to your `WORKSPACE` file and update versions with their sha256s if needed:

```starlark
# WORKSPACE
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

skylib_version = "1.0.3"
http_archive(
    name = "bazel_skylib",
    sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
    type = "tar.gz",
    url = "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib-{}.tar.gz".format(skylib_version, skylib_version),
)

rules_scala_version = "e7a948ad1948058a7a5ddfbd9d1629d6db839933"
http_archive(
    name = "io_bazel_rules_scala",
    sha256 = "76e1abb8a54f61ada974e6e9af689c59fd9f0518b49be6be7a631ce9fa45f236",
    strip_prefix = "rules_scala-%s" % rules_scala_version,
    type = "zip",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % rules_scala_version,
)

# Stores Scala version and other configuration
# 2.12 is a default version, other versions can be use by passing them explicitly:
# scala_config(scala_version = "2.11.12")
load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")
scala_config()

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
scala_repositories()

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies", "rules_proto_toolchains")
rules_proto_dependencies()
rules_proto_toolchains()

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
scala_register_toolchains()

# optional: setup ScalaTest toolchain and dependencies
load("@io_bazel_rules_scala//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")
scalatest_repositories()
scalatest_toolchain()
```

This will load the `rules_scala` repository at the commit sha
`rules_scala_version` into your Bazel project and register a [Scala
toolchain](#scala_toolchain) at the default Scala version (2.12.11)

Then in your BUILD file just add the following so the rules will be available:
```python
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library", "scala_binary", "scala_test")
```
You may wish to have these rules loaded by default using bazel's prelude. You can add the above to the file `tools/build_rules/prelude_bazel` in your repo (don't forget to have a, possibly empty, BUILD file there) and then it will be automatically prepended to every BUILD file in the workspace.

To run with a persistent worker (much faster), you need to add
```
build --strategy=Scalac=worker
build --worker_sandboxing
```
to your command line, or to enable by default for building/testing add it to your .bazelrc.

## Coverage support

It will produce several .dat files with results for your targets.

You can also add more options to receive a combined coverage report:

```
bazel coverage \
  --combined_report=lcov \
  --coverage_report_generator="@bazel_tools//tools/test/CoverageOutputGenerator/java/com/google/devtools/coverageoutputgenerator:Main" \
  //...
```

This should produce a single `bazel-out/_coverage/_coverage_report.dat` from all coverage files that are generated.

You can extract information from your coverage reports with `lcov`:

```
# For a summary:
lcov --summary your-coverage-report.dat
# For details:
lcov --list your-coverage-report.dat
```

If you prefer an HTML report, then you can use `genhtml` provided also by the `lcov` package.

Coverage support has been only tested with [ScalaTest](http://www.scalatest.org/).

Please check [coverage.md](docs/coverage.md) for more details on coverage support.

## Selecting Scala version

### With toolchains

Rules scala supports the last two released minor versions for each of Scala 2.11, 2.12, 2.13.
Previous minor versions may work but are supported only on a best effort basis.

To configure Scala version you must call `scala_config(scala_version = "2.xx.xx")` and configure 
dependencies by declaring [scala_toolchain](https://github.com/bazelbuild/rules_scala/blob/master/docs/scala_toolchain.md). 
For a quick start you can use `scala_repositories()` and `scala_register_toolchains()`, which have 
dependency providers configured for `2.11.12`, `2.12.11` and `2.13.3` versions.

```starlark
# WORKSPACE
load("@io_bazel_rules_scala//:scala_config.bzl", "scala_config")
scala_config(scala_version = "2.13.3")

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
scala_repositories()

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
scala_register_toolchains()
```

If you're using any of the rules `twitter_scrooge`, `scala_proto_repositories`
or `specs2_junit_repositories` you also need to specify `scala_version` for them. See `./test_version/WORKSPACE.template`
for an example workspace using another scala version.

### As an option for `scala_repositories()`

It's also possible to override the scala artifacts while calling `scala_repositories()`:

```starlark
scala_repositories(
  overriden_artifacts = {
    # Change both the artifact names and sha256s.
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:2.12.14",
        "sha256": "0451dce8322903a6c2aa7d31232b54daa72a61ced8ade0b4c5022442a3f6cb57",
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala-compiler:2.12.14",
        "sha256": "2a1b3fbf9c956073c8c5374098a6f987e3b8d76e34756ab985fc7d2ca37ee113",
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:2.12.14",
        "sha256": "497f4603e9d19dc4fa591cd467de5e32238d240bbd955d3dac6390b270889522",
    }
  }
)
```

Note: Toolchains are a more flexible way to configure dependencies, so you should prefer that way.
Please also note, that the `overriden_artifacts` parameter is likely to be removed in the future.

## Bazel compatible versions

| minimal bazel version | rules_scala gitsha |
|--------|--------------------|
| 4.1.0  | HEAD               |
| 3.5.0  | 0f55e9f8cff6494bbff7cd57048d732286a520f5 /               |
| 2.0.0  | 116709091e5e1aab3346184217b565f4cb7ba4eb |
| 1.1.0  | d681a952da74fc61a49fc3167b03548f42fc5dde |
| 0.28.1 | bd0c388125e12f4f173648fc4474f73160a5c628 |
| 0.23.x | ca655e5a330cbf1d66ce1d9baa63522752ec6011 |
| 0.22.x | f3113fb6e9e35cb8f441d2305542026d98afc0a2 |
| 0.16.x | f3113fb6e9e35cb8f441d2305542026d98afc0a2 |
| 0.15.x | 3b9ab9be31ac217d3337c709cb6bfeb89c8dcbb1 |
| 0.14.x | 3b9ab9be31ac217d3337c709cb6bfeb89c8dcbb1 |
| 0.13.x | 3c987b6ae8a453886759b132f1572c0efca2eca2 |

PRs are also built with highest supported bazel version (see [Travis config](https://github.com/bazelbuild/rules_scala/blob/master/.travis.yml) for the exact highest version)

## Breaking changes

If you're upgrading to a version containing one of these commits, you may encounter a breaking change where there was previously undefined behavior.

- [929b318](https://github.com/bazelbuild/rules_scala/commit/929b3180cc099ba76859f5e88710d2ac087fbfa3) on 2020-01-30: Fixed a bug in the JMH benchmark build that was allowing build failures to creep through. Previously you were able to build a benchmark suite with JMH build errors. Running the benchmark suite would only run the successfully-built benchmarks.

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
Go [here](docs/publish_to_maven.md)

## Dependency Tracking
Rules Scala supports multiple dependency modes including strict and unused dependency tracking. See
[Dependency Tracking](docs/dependency-tracking.md) for more info.

## Advanced configurable rules
To make the ruleset more flexible and configurable, we introduce a phase architecture. By using a phase architecture, where rule implementations are defined as a list of phases that are executed sequentially, functionality can easily be added (or modified) by adding (or swapping) phases.

Phases provide 3 major benefits:
 - Consumers are able to configure the rules to their specific use cases by defining new phases within their workspace without impacting other consumers.
 - Contributors are able to implement new functionalities by creating additional default phases.
 - Phases give us more clear idea what steps are shared across rules.

See [Customizable Phase](docs/customizable_phase.md) for more info.

### Phase extensions
 - [Scala Format](docs/phase_scalafmt.md)

## Building from source
Setup bazel:
We recommend using [Bazelisk](https://docs.bazel.build/versions/master/install.html) as your default bazel binary

Test & Build:
```
bash test_all.sh
```

You can also use:
```
bazel test //test/...
```
Note `bazel test //...` will not work since we have a sub-folder on the root folder which is meant to be used in a failure scenario in the integration tests.
Similarly to only build you should use `bazel build //src/...` due to that folder.

## Updates
This section contains a list of updates that might require action from the user.

 - [`043ba58`](https://github.com/bazelbuild/rules_scala/commit/043ba58afaf90bf571911123d3353bdf20408a33):
 Updates default scrooge version to `18.6.0`
 - [`76d4ab9`](https://github.com/bazelbuild/rules_scala/commit/76d4ab9f855f78113ee5990a84b0ad55d2417e4a):
 Updates naming for scala artifact replacements in bazel-deps. See [Usage with bazel-deps](#usage-with-bazel-deps)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more info.

## Adopters

Here's a (non-exhaustive) list of companies that use `rules_scala` in production. Don't see yours? [You can add it in a PR](https://github.com/bazelbuild/rules_scala/edit/master/README.md)!

* [Ascend](https://ascend.io/)
* [Canva](https://www.canva.com/)
* [Domino Data Lab](https://www.dominodatalab.com/)
* [Etsy](https://www.etsy.com/)
* [Gemini](https://gemini.com/)
* [Grand Rounds](http://grandrounds.com/)
* [Kitty Hawk](https://kittyhawk.aero/)
* [Meetup](https://meetup.com/)
* [Spotify](https://www.spotify.com/)
* [Stripe](https://stripe.com/)
* [Twitter](https://twitter.com/)
* [VSCO](https://vsco.co)
* [Wix](https://www.wix.com/)
