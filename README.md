# Scala Rules for Bazel
[![Build Status](https://travis-ci.org/bazelbuild/rules_scala.svg?branch=master)](https://travis-ci.org/bazelbuild/rules_scala) [![Build status](https://badge.buildkite.com/90ce5244556df74db805a3c24a703fb87458396f9e1ddd687e.svg)](https://buildkite.com/bazel/scala-rules-scala-postsubmit) [![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/bazelbuild_rules_scala/Lobby)

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

1. [Install Bazel](https://docs.bazel.build/versions/master/install.html), see the [compatibility table](#bazel-compatible-versions).
2. Add the following to your `WORKSPACE` file and update the `githash` if needed:

```python
rules_scala_version="69d3c5b5d9b51537231746e93b4383384c9ebcf4" # update this as needed

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "io_bazel_rules_scala",
    strip_prefix = "rules_scala-%s" % rules_scala_version,
    type = "zip",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % rules_scala_version,
)

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
scala_register_toolchains()

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
scala_repositories()

protobuf_version="09745575a923640154bcf307fba8aedff47f240a"
protobuf_version_sha256="416212e14481cff8fd4849b1c1c1200a7f34808a54377e22d7447efdf54ad758"

http_archive(
    name = "com_google_protobuf",
    url = "https://github.com/protocolbuffers/protobuf/archive/%s.tar.gz" % protobuf_version,
    strip_prefix = "protobuf-%s" % protobuf_version,
    sha256 = protobuf_version_sha256,
)

# bazel-skylib 0.8.0 released 2019.03.20 (https://github.com/bazelbuild/bazel-skylib/releases/tag/0.8.0)
skylib_version = "0.8.0"
http_archive(
    name = "bazel_skylib",
    type = "tar.gz",
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib.{}.tar.gz".format (skylib_version, skylib_version),
    sha256 = "2ef429f5d7ce7111263289644d233707dba35e39696377ebab8b0bc701f7818e",
)
```

This will load the `rules_scala` repository at the commit sha
`rules_scala_version` into your Bazel project and register a [Scala
toolchain](#scala_toolchain) at the default Scala version (2.11.12)

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

## Selecting Scala version

Rules scala supports all minor versions of Scala 2.11/2.12. By default `Scala 2.11.12` is used and to use another
version you need to
specify it when calling `scala_repositories`. `scala_repositories` takes a tuple `(scala_version, scala_version_jar_shas)`
as a parameter where `scala_version` is the scala version and `scala_version_jar_shas` is a `dict` with
`sha256` hashes for the maven artifacts `scala_compiler`, `scala_library`, and `scala_reflect`:

```python
scala_repositories((
    "2.12.10",
    {
       "scala_compiler": "cedc3b9c39d215a9a3ffc0cc75a1d784b51e9edc7f13051a1b4ad5ae22cfbc0c",
       "scala_library": "0a57044d10895f8d3dd66ad4286891f607169d948845ac51e17b4c1cf0ab569d",
       "scala_reflect": "56b609e1bab9144fb51525bfa01ccd72028154fc40a58685a1e9adcbe7835730"
    }
))
```

If you're using any of the rules `twitter_scrooge`, `tut_repositories`, `scala_proto_repositories`
or `specs2_junit_repositories` you also need to specify `scala_version` for them. See `./test_version/WORKSPACE.template`
for an example workspace using another scala version.


## Bazel compatible versions

| bazel  | rules_scala gitsha |
|--------|--------------------|
| 2.0.0  | HEAD               |
| 0.28.1 | HEAD               |
| 0.23.x | ca655e5a330cbf1d66ce1d9baa63522752ec6011 |                                     |
| 0.22.x | f3113fb6e9e35cb8f441d2305542026d98afc0a2 |
| 0.16.x | f3113fb6e9e35cb8f441d2305542026d98afc0a2 |
| 0.15.x | 3b9ab9be31ac217d3337c709cb6bfeb89c8dcbb1 |
| 0.14.x | 3b9ab9be31ac217d3337c709cb6bfeb89c8dcbb1 |
| 0.13.x | 3c987b6ae8a453886759b132f1572c0efca2eca2 |

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

## [Experimental] Using strict-deps
Bazel pushes towards explicit and minimal dependencies to keep BUILD file hygiene and allow for targets to refactor their dependencies without fear of downstream breaking.
Currently rules_scala does this at the cost of having cryptic `scalac` errors when one mistakenly depends on a transitive dependency or, as more often the case for some, a transitive dependency is needed to [please scalac](https://github.com/scalacenter/advisoryboard/blob/master/proposals/009-improve-direct-dependency-experience.md) itself.
To learn more about the motivation of strict-deps itself you can visit this Bazel blog [post](https://blog.bazel.build/2017/06/28/sjd-unused_deps.html) on the subject.

To use it just add `--strict_java_deps=WARN|ERROR` to your `bazel` invocation.
In both cases of `WARN` or `ERROR` you will get the following text in the event of a violation:
```
...
Target '//some_package:transitive_dependency' is used but isn't explicitly declared, please add it to the deps.
You can use the following buildozer command:
buildozer 'add deps //some_package:transitive_dependency' //some_other_package:transitive_dependency_user
```
Note that if you have `buildozer` installed you can just run the last line and have it automatically apply the fix for you.

**Caveats:**
<ul>
    <li>Extra builds- when strict-deps is on the transitive dependencies are inputs to the compilation action which means you can potentially have more build triggers for changes the cross the ijar boundary </li>
    <li>Label propagation- since label of targets are needed for the clear message and since it's not currently supported by JavaInfo from bazel we manually propagate it. This means that the error messages have a significantly lower grade if you don't use one of the scala rules or scala_import (since they don't propagate these labels)</li>
    <li>javac outputs incorrect targets due to a problem we're tracing down. Practically we've noticed it's pretty trivial to understand the correct target (i.e. it's almost a formatting problem) </li>
  </ul>

Note: Currently strict-deps is protected by a feature toggle but we're strongly considering making it the default behavior as `java_*` rules do.

## [Experimental] Unused dependency checking
To allow for better caching and faster builds we want to minimize the direct dependencies of our targets. Unused dependency checking
makes sure that all targets specified as direct dependencies are actually used. If `unused_dependency_checker_mode` is set to either
`error` or `warn` you will get the following message for any dependencies that are not used:
```
error: Target '//some_package:unused_dep' is specified as a dependency to //target:target but isn't used, please remove it from the deps.
You can use the following buildozer command:
buildozer 'remove deps //some_package:unused_dep' //target:target
```

Currently unused dependency checking and strict-deps can't be used simultaneously, if both are set only strict-deps will run.

Unused dependency checking can either be enabled globally for all targets using a scala toolchain or for individual targets using the
`unused_dependency_checker_mode` attribute. The feature is still experimental and there can thus be cases where it works incorrectly,
in these cases you can enable unused dependency checking globally through a toolchain and override individual misbehaving targets
using the attribute.

## Advanced configurable rules
To make the ruleset more flexible and configurable, we introduce a phase architecture. By using a phase architecture, where rule implementations are defined as a list of phases that are executed sequentially, functionality can easily be added (or modified) by adding (or swapping) phases.

Phases provide 3 major benefits:
 - Consumers are able to configure the rules to their specific use cases by defining new phases within their workspace without impacting other consumers.
 - Contributors are able to implement new functionalities by creating additional default phases.
 - Phases give us more clear idea what steps are shared across rules.

See [Customizable Phase](docs/customizable_phase.md) for more info.

## Building from source
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
* [Etsy](https://www.etsy.com/)
* [Grand Rounds](http://grandrounds.com/)
* [Kitty Hawk](https://kittyhawk.aero/)
* [Meetup](https://meetup.com/)
* [Spotify](https://www.spotify.com/)
* [Stripe](https://stripe.com/)
* [VSCO](https://vsco.co)
* [Wix](https://www.wix.com/)
