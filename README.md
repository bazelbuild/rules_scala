# Scala Rules for Bazel
[![Build Status](https://travis-ci.org/bazelbuild/rules_scala.svg?branch=master)](https://travis-ci.org/bazelbuild/rules_scala) [![Build status](https://badge.buildkite.com/90ce5244556df74db805a3c24a703fb87458396f9e1ddd687e.svg?branch=master)](https://buildkite.com/bazel/scala-rules-scala-postsubmit) [![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/bazelbuild_rules_scala/Lobby)

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
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# bazel-skylib 0.8.0 released 2019.03.20 (https://github.com/bazelbuild/bazel-skylib/releases/tag/0.8.0)
skylib_version = "0.8.0"
http_archive(
    name = "bazel_skylib",
    type = "tar.gz",
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib.{}.tar.gz".format (skylib_version, skylib_version),
    sha256 = "2ef429f5d7ce7111263289644d233707dba35e39696377ebab8b0bc701f7818e",
)

rules_scala_version="a2f5852902f5b9f0302c727eead52ca2c7b6c3e2" # update this as needed

http_archive(
    name = "io_bazel_rules_scala",
    strip_prefix = "rules_scala-%s" % rules_scala_version,
    type = "zip",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip" % rules_scala_version,
    sha256 = "8c48283aeb70e7165af48191b0e39b7434b0368718709d1bced5c3781787d8e7",
)

load("@io_bazel_rules_scala//:version.bzl", "bazel_version")
bazel_version(name = "bazel_version")

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
scala_register_toolchains()

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
scala_repositories()

protobuf_version="3.11.3"
protobuf_version_sha256="cf754718b0aa945b00550ed7962ddc167167bd922b842199eeb6505e6f344852"

http_archive(
    name = "com_google_protobuf",
    url = "https://github.com/protocolbuffers/protobuf/archive/v%s.tar.gz" % protobuf_version,
    strip_prefix = "protobuf-%s" % protobuf_version,
    sha256 = protobuf_version_sha256,
)

# Dependencies needed for google_protobuf.
# You may need to modify this if your project uses google_protobuf for other purposes.
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
protobuf_deps()
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

## Coverage support

rules_scala supports coverage, but it's disabled by default. You need to enable it with an extra toolchain:

```
bazel coverage --extra_toolchains="@io_bazel_rules_scala//scala:code_coverage_toolchain" //...
```

It will produce several .dat files with results for your targets.

You can also add more options to receive a combined coverage report:

```
bazel coverage \
  --extra_toolchains="@io_bazel_rules_scala//scala:code_coverage_toolchain" \
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

Rules scala supports the last two released minor versions for each of Scala 2.11 and 2.12.
Previous minor versions may work but are supported only on a best effort basis.

By default `Scala 2.12.10` is used and to use another version you need to
specify it when calling `scala_repositories`. `scala_repositories` takes a tuple `(scala_version, scala_version_jar_shas)`
as a parameter where `scala_version` is the scala version and `scala_version_jar_shas` is a `dict` with
`sha256` hashes for the maven artifacts `scala_compiler`, `scala_library`, and `scala_reflect`:

```python
scala_repositories((
    "2.11.12",
    {
        "scala_compiler": "3e892546b72ab547cb77de4d840bcfd05c853e73390fed7370a8f19acb0735a0",
        "scala_library": "0b3d6fd42958ee98715ba2ec5fe221f4ca1e694d7c981b0ae0cd68e97baf6dce",
        "scala_reflect": "6ba385b450a6311a15c918cf8688b9af9327c6104f0ecbd35933cfcd3095fe04",
    }
))
```

If you're using any of the rules `twitter_scrooge`, `tut_repositories`, `scala_proto_repositories`
or `specs2_junit_repositories` you also need to specify `scala_version` for them. See `./test_version/WORKSPACE.template`
for an example workspace using another scala version.


## Bazel compatible versions

| minimal bazel version | rules_scala gitsha |
|--------|--------------------|
| 3.5.0  | HEAD               |
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

## [Experimental] Dependency options

There are a number of dependency options which can be set in the scala toolchain. These include `dependency_mode`, `strict_deps_mode`, `unused_dependency_checker_mode`, and `dependency_tracking_method`.

### [Experimental] Recommended options

We recommend one of the following sets of options

**Option A**
Accept the defaults, which might work well enough for you. The defaults are
```
  dependency_mode = "direct",
  strict_deps_mode = "off",
  unused_dependency_checker_mode = "off",
  dependency_tracking_method = "high-level",
```
but you do not need to include this in the toolchain as they are the defaults.

**Option B**
```
  dependency_mode = "plus-one",
  strict_deps_mode = "error",
  unused_dependency_checker_mode = "error",
  dependency_tracking_method = "ast",
```

Should the first option result in too much effort in handling build files and the like due to confusing dependencies and you becoming confused as to why some specific dependency is needed when the code being compiled never references it, consider this set of options. It will include both dependencies and dependencies of dependencies, which in practice is enough to stop almost all strange missing dependency errors at the cost of somewhat more incremental compile cost in certain cases.

With these settings, we also will error on dependencies which are unneeded, and dependencies which should be included in `deps` due to be directly referenced in the code, but are not.

The dependency tracking method `ast` is experimental but so far proves to be better than the default for computing the direct dependencies for `plus-one` mode code. In the future we hope to make this the default for `plus-one` mode and remove the option altogether.

To try it out you can use the following toolchain: `//scala:minimal_direct_source_deps`.

### [Experimental] Dependency mode

There are three dependency modes. The reason for the multiple modes is that often `scalac` depends on jars which seem unnecessary at first glance. Hence, in order to reduce the need to please `scalac`, we provide the following options.
- `dependency_mode = "direct"` - only include direct dependencies during compiliation; that is, those in the `deps` attribute
- `dependency_mode = "plus-one"` - only include `deps` and `deps` of `deps` during compiliation.
- `dependency_mode = "transitive"` - all transitive dependencies are included during compiliation. That is, `deps`, `deps` of `deps`, `deps` of `deps` of `deps`, and so on.

Note when a dependency is included, that means its jars are included on the classpath, along with the jars of any targets that it exports.

When using `direct` mode, there can be cryptic `scalac` errors when one mistakenly depends on a transitive dependency or, as more often the case for some, a transitive dependency is needed to [please scalac](https://github.com/scalacenter/advisoryboard/blob/master/proposals/009-improve-direct-dependency-experience.md) itself.

As one goes down the list, more dependencies are included which helps reduce confusing requirements to add `deps`, at the cost of increased incremental builds due to a greater number of dependencies. In practice, using `plus-one` deps results in almost no confusing `deps` entries required while still being relatively small in terms of the number of total dependencies included.

**Caveats for `plus_one` and `transitive`:**
<ul>
    <li>Extra builds- Extra dependencies are inputs to the compilation action which means you can potentially have more build triggers for changes the cross the ijar boundary </li>
    <li>Label propagation- since label of targets are needed for the clear message and since it's not currently supported by JavaInfo from bazel we manually propagate it. This means that the error messages have a significantly lower grade if you don't use one of the scala rules or scala_import (since they don't propagate these labels)</li>
    <li>javac outputs incorrect targets due to a problem we're tracing down. Practically we've noticed it's pretty trivial to understand the correct target (i.e. it's almost a formatting problem) </li>
  </ul>

Note: the last two issues are bugs which will be addressed by [https://github.com/bazelbuild/rules_scala/issues/839].

### [Experimental] Strict deps mode
We have a strict dependency checker which requires that any type referenced in the sources of a scala target should be included in that rule's deps. To learn about the motivation for this you can visit this Bazel blog [post](https://blog.bazel.build/2017/06/28/sjd-unused_deps.html) on the subject.

The option `strict_deps_mode` can be set to `off`, `warn`, or `error`. We highly recommend setting it to `error`.

In both cases of `warn` or `error` you will get the following text in the event of a violation:
```
...
Target '//some_package:transitive_dependency' is used but isn't explicitly declared, please add it to the deps.
You can use the following buildozer command:
buildozer 'add deps //some_package:transitive_dependency' //some_other_package:transitive_dependency_user
```
Note that if you have `buildozer` installed you can just run the last line and have it automatically apply the fix for you.

Note that this option only applies to scala code. Any java code, even that within `scala_library` and other rules_scala rules, is still controlled by the `--strict_java_deps` command-line flag.

### [Experimental] Unused dependency checking
To allow for better caching and faster builds we want to minimize the direct dependencies of our targets. Unused dependency checking
makes sure that all targets specified as direct dependencies are actually used. If `unused_dependency_checker_mode` is set to either
`error` or `warn` you will get the following message for any dependencies that are not used:
```
error: Target '//some_package:unused_dep' is specified as a dependency to //target:target but isn't used, please remove it from the deps.
You can use the following buildozer command:
buildozer 'remove deps //some_package:unused_dep' //target:target
```

Unused dependency checking can either be enabled globally for all targets using a scala toolchain or for individual targets using the
`unused_dependency_checker_mode` attribute.

The feature is still experimental and there can thus be cases where it works incorrectly, in these cases you can enable unused dependency checking globally through a toolchain and disable reports of individual misbehaving targets with `unused_dependency_checker_ignored_targets` which is a list of labels.

### [Experimental] Dependency tracking method

The strict dependency tracker and unused dependency tracker need to track the used dependencies of a scala compilation unit. This toggle allows one to pick which method of tracking to use.

- `dependency_tracking_method = "high-level"` - This is the existing tracking method which has false positives and negatives but generally works reasonably well for `direct` dependency mode.
- `dependency_tracking_method = "ast"` - This is a new tracking method which is being developed for `plus-one` and `transitive` dependency modes. It is still being developed and may have issues which need fixing. If you discover an issue, please submit a small repro of the problem.

By default, `plus-one` and `transitive` dependency modes will use the `ast` dependency tracking method, while `direct` mode will use the `high-level` dependency tracking method.

Note we intend to eventually remove this flag and make the defaults non-configurable.

### [Experimental] Turning on strict_deps_mode/unused_dependency_checker_mode

It can be daunting to turn on strict deps checking or unused dependency mode checking on a large codebase. However, it need not be so bad if this is done in phases

1. Have a default scala toolchain `A` with the option of interest set to `off` (the starting state)
2. Create a second scala toolchain `B` with the option of interest set to `warn` or `error`. Those who are working on enabling the flag can run with this toolchain as a command line argument to help identify issues and fix them.
3. Once all issues are fixed, change `A` to have the option of interest set to `error` and delete `B`.

We recommend turning on strict_deps_mode first, as rule `A` might have an entry `B` in its `deps`, and `B` in turn depends on `C`. Meanwhile, the code of `A` only uses `C` but not `B`. Hence, the unused dependency checker, if on, will request that `B` be removed from `A`'s deps. But this will lead to a compile error as `A` can no longer depend on `C`. However, if strict dependency checking was on, then `A`'s deps is guaranteed to have `C` in it.

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
* [Etsy](https://www.etsy.com/)
* [Grand Rounds](http://grandrounds.com/)
* [Kitty Hawk](https://kittyhawk.aero/)
* [Meetup](https://meetup.com/)
* [Spotify](https://www.spotify.com/)
* [Stripe](https://stripe.com/)
* [VSCO](https://vsco.co)
* [Wix](https://www.wix.com/)
