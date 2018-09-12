# Scala Rules for Bazel
[![Build Status](https://travis-ci.org/bazelbuild/rules_scala.svg?branch=master)](https://travis-ci.org/bazelbuild/rules_scala) [![Build status](https://badge.buildkite.com/90ce5244556df74db805a3c24a703fb87458396f9e1ddd687e.svg)](https://buildkite.com/bazel/scala-rules-scala-postsubmit) [![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/bazelbuild_rules_scala/Lobby)

<div class="toc">
  <h2>Rules</h2>
  <ul>
    <li><a href="#scala_library">scala_library/scala_macro_library</a></li>
    <li><a href="#scala_binary">scala_binary</a></li>
    <li><a href="#scala_test">scala_test</a></li>
    <li><a href="#scalapb_proto_library">scalapb_proto_library</a></li>
  </ul>
</div>

## Overview

This rule is used for building [Scala][scala] projects with Bazel. There are
currently four rules, `scala_library`, `scala_macro_library`, `scala_binary`
and `scala_test`.

## Getting started

In order to use `scala_library`, `scala_macro_library`, and `scala_binary`,
you must have bazel 0.5.3 or later and add the following to your WORKSPACE file:

```python

rules_scala_version="a89d44f7ef67d93dedfc9888630f48d7723516f7" # update this as needed

http_archive(
             name = "io_bazel_rules_scala",
             url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip"%rules_scala_version,
             type = "zip",
             strip_prefix= "rules_scala-%s" % rules_scala_version
             )

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")
scala_repositories()
```
To use a particular tag, use the tagged number in `tag = ` and omit the `commit` attribute.
Note that these plugins are still evolving quickly, as is bazel, so you may need to select
the version most appropriate for you.

In addition, you **must** register `scala_toolchain` - To register default empty toolcahin simply add those lines to `WORKSPACE` file:
```python

load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
scala_register_toolchains()
```
[read more here](#scala_toolchain)

Then in your BUILD file just add the following so the rules will be available:
```python
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library", "scala_binary", "scala_test")
```
You may wish to have these rules loaded by default using bazel's prelude. You can add the above to the file `tools/build_rules/prelude_bazel` in your repo (don't forget to have a, possibly empty, BUILD file there) and then it will be automatically prepended to every BUILD file in the workspace.

To run with a persistent worker (much faster), you need to add
```
build --strategy=Scalac=worker
test --strategy=Scalac=worker
```
to your command line, or to enable by default for building/testing add it to your .bazelrc.

## Selecting Scala version

Rules scala supports all minor versions of Scala 2.11/2.12. By default `Scala 2.11.12` is used and to use another
version you need to
specify it when calling `scala_repositories`. `scala_repositories` takes a tuple `(scala_version, scala_version_jar_shas)`
as a parameter where `scala_version` is the scala version and `scala_version_jar_shas` is a `dict` with
`sha256` hashes for the maven artifacts `scala_library`, `scala_reflect` and `scala_compiler`:
```python
scala_repositories(("2.12.6", {
    "scala_compiler": "3023b07cc02f2b0217b2c04f8e636b396130b3a8544a8dfad498a19c3e57a863",
    "scala_library": "f81d7144f0ce1b8123335b72ba39003c4be2870767aca15dd0888ba3dab65e98",
    "scala_reflect": "ffa70d522fc9f9deec14358aa674e6dd75c9dfa39d4668ef15bb52f002ce99fa"
}))
```
If you're using any of the rules `twitter_scrooge`, `tut_repositories`, `scala_proto_repositories`
or `specs2_junit_repositories` you also need to specify `scala_version` for them. See `./test_version/WORKSPACE.template`
for an example workspace using another scala version.


## Bazel compatible versions

| bazel | rules_scala gitsha |
|-------|--------------------|
| 0.16.x | HEAD              |
| 0.15.x | 3b9ab9be31ac217d3337c709cb6bfeb89c8dcbb1 |
| 0.14.x | 3b9ab9be31ac217d3337c709cb6bfeb89c8dcbb1 |
| 0.13.x | 3c987b6ae8a453886759b132f1572c0efca2eca2 |

[scala]: http://www.scala-lang.org/

<a name="scala_library"></a>
## scala\_library / scala\_macro_library

```python
scala_library(name, srcs, deps, runtime_deps, exports, data, main_class, resources, resource_strip_prefix, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags, unused_dependency_checker_mode)
scala_macro_library(name, srcs, deps, runtime_deps, exports, data, main_class, resources, resource_strip_prefix, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags, unused_dependency_checker_mode)
```

`scala_library` generates a `.jar` file from `.scala` source files. This rule
also creates an interface jar to avoid recompiling downstream targets unless
their interface changes.

`scala_macro_library` generates a `.jar` file from `.scala` source files when
they contain macros. For macros, there are no interface jars because the macro
code is executed at compile time. For best performance, you want very granular
targets until such time as the zinc incremental compiler can be supported.

In order to make a java rule use this jar file, use the `java_import` rule.

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <p><code>Name, required</code></p>
        <p>A unique name for this target</p>
      </td>
    </tr>
      <td><code>srcs</code></td>
      <td>
        <p><code>List of labels, required</code></p>
        <p>List of Scala <code>.scala</code> source files used to build the
        library. These may be .srcjar jar files that contain source code.</p>
      </td>
    </tr>
    <tr>
      <td><code>deps</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of other libraries to linked to this library target.
        These must be jvm targets (scala_library, java_library, java_import, etc...)</p>
      </td>
    </tr>
    <tr>
      <td><code>runtime_deps</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of other libraries to put on the classpath only at runtime. This is rarely needed in Scala.
        These must be jvm targets (scala_library, java_library, java_import, etc...)</p>
      </td>
    </tr>
    <tr>
      <td><code>exports</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of targets to add to the dependencies of those that depend on this target. Similar
        to the `java_library` parameter of the same name. Use this sparingly as it weakens the
        precision of the build graph.
        These must be jvm targets (scala_library, java_library, java_import, etc...)</p>
      </td>
    </tr>
    <tr>
      <td><code>data</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of files needed by this rule at runtime.</p>
      </td>
    </tr>
    <tr>
      <td><code>main_class</code></td>
      <td>
        <p><code>String, optional</code></p>
        <p>Name of class with main() method to use as an entry point</p>
        <p>
          The value of this attribute is a class name, not a source file. The
          class must be available at runtime: it may be compiled by this rule
          (from <code>srcs</code>) or provided by direct or transitive
          dependencies (through <code>deps</code>). If the class is unavailable,
          the binary will fail at runtime; there is no build-time check.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>resources</code></td>
      <td>
        <p><code>List of labels; optional</code></p>
        <p>A list of data files to be included in the JAR.</p>
      </td>
    </tr>
    <tr>
      <td><code>resource_strip_prefix</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>
          The path prefix to strip from Java resources. If specified,
          this path prefix is stripped from every file in the `resources` attribute.
          It is an error for a resource file not to be under this directory.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>scalacopts</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          Extra compiler options for this library to be passed to scalac. Subject to
          <a href="http://bazel.io/docs/be/make-variables.html">Make variable
          substitution</a> and
          <a href="http://bazel.io/docs/be/common-definitions.html#borne-shell-tokenization">Bourne shell tokenization.</a>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>jvm_flags</code></td>
      <td>
        <p><code>List of strings; optional; deprecated</code></p>
        <p>
          Deprecated, superseded by scalac_jvm_flags and javac_jvm_flags. Is not used and is kept as backwards compatibility for the near future. Effectively jvm_flags is now an executable target attribute only.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>scalac_jvm_flags</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          List of JVM flags to be passed to scalac after the
          <code>scalacopts</code>. Subject to
          <a href="http://bazel.io/docs/be/make-variables.html">Make variable
          substitution</a> and
          <a href="http://bazel.io/docs/be/common-definitions.html#borne-shell-tokenization">Bourne shell tokenization.</a>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>javac_jvm_flags</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          List of JVM flags to be passed to javac after the
          <code>javacopts</code>. Subject to
          <a href="http://bazel.io/docs/be/make-variables.html">Make variable
          substitution</a> and
          <a href="http://bazel.io/docs/be/common-definitions.html#borne-shell-tokenization">Bourne shell tokenization.</a>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>unused_dependency_checker_mode</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>
          Enable unused dependency checking (see <a href="https://github.com/bazelbuild/rules_scala#experimental-unused-dependency-checking">Unused dependency checking</a>).
          Possible values are: <code>off</code>, <code>warn</code> and <code>error</code>.
        </p>
      </td>
    </tr>
  </tbody>
</table>

<a name="scala_binary"></a>
## scala_binary

```python
scala_binary(name, srcs, deps, runtime_deps, data, main_class, resources, resource_strip_prefix, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags, unused_dependency_checker_mode)
```

`scala_binary` generates a Scala executable. It may depend on `scala_library`, `scala_macro_library`
and `java_library` rules.

A `scala_binary` requires a `main_class` attribute.

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <p><code>Name, required</code></p>
        <p>A unique name for this target</p>
      </td>
    </tr>
      <td><code>srcs</code></td>
      <td>
        <p><code>List of labels, required</code></p>
        <p>List of Scala <code>.scala</code> source files used to build the
        binary</p>
      </td>
    </tr>
    <tr>
      <td><code>deps</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of other libraries to linked to this binary target.
        These must be jvm targets (scala_library, java_library, java_import, etc...)</p>
      </td>
    </tr>
    <tr>
      <td><code>runtime_deps</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of other libraries to put on the classpath only at runtime. This is rarely needed in Scala.
        These must be jvm targets (scala_library, java_library, java_import, etc...)</p>
      </td>
    </tr>
    <tr>
      <td><code>data</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of files needed by this rule at runtime.</p>
      </td>
    </tr>
    <tr>
      <td><code>main_class</code></td>
      <td>
        <p><code>String, required</code></p>
        <p>Name of class with main() method to use as an entry point</p>
        <p>
          The value of this attribute is a class name, not a source file. The
          class must be available at runtime: it may be compiled by this rule
          (from <code>srcs</code>) or provided by direct or transitive
          dependencies (through <code>deps</code>). If the class is unavailable,
          the binary will fail at runtime; there is no build-time check.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>resources</code></td>
      <td>
        <p><code>List of labels; optional</code></p>
        <p>A list of data files to be included in the JAR.</p>
      </td>
    </tr>
    <tr>
      <td><code>resource_strip_prefix</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>
          The path prefix to strip from Java resources. If specified,
          this path prefix is stripped from every file in the `resources` attribute.
          It is an error for a resource file not to be under this directory.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>scalacopts</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          Extra compiler options for this binary to be passed to scalac. Subject to
          <a href="http://bazel.io/docs/be/make-variables.html">Make variable
          substitution</a> and
          <a href="http://bazel.io/docs/be/common-definitions.html#borne-shell-tokenization">Bourne shell tokenization.</a>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>jvm_flags</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          List of JVM flags to be passed to the executing JVM. Subject to
          <a href="http://bazel.io/docs/be/make-variables.html">Make variable
          substitution</a> and
          <a href="http://bazel.io/docs/be/common-definitions.html#borne-shell-tokenization">Bourne shell tokenization.</a>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>scalac_jvm_flags</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          List of JVM flags to be passed to scalac after the
          <code>scalacopts</code>. Subject to
          <a href="http://bazel.io/docs/be/make-variables.html">Make variable
          substitution</a> and
          <a href="http://bazel.io/docs/be/common-definitions.html#borne-shell-tokenization">Bourne shell tokenization.</a>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>javac_jvm_flags</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          List of JVM flags to be passed to javac after the
          <code>javacopts</code>. Subject to
          <a href="http://bazel.io/docs/be/make-variables.html">Make variable
          substitution</a> and
          <a href="http://bazel.io/docs/be/common-definitions.html#borne-shell-tokenization">Bourne shell tokenization.</a>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>unused_dependency_checker_mode</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>
          Enable unused dependency checking (see <a href="https://github.com/bazelbuild/rules_scala#experimental-unused-dependency-checking">Unused dependency checking</a>).
          Possible values are: <code>off</code>, <code>warn</code> and <code>error</code>.
        </p>
      </td>
    </tr>
  </tbody>
</table>

<a name="scala_test"></a>
## scala_test

```python
scala_test(name, srcs, suites, deps, data, main_class, resources, resource_strip_prefix, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags, unused_dependency_checker_mode)
```

`scala_test` generates a Scala executable which runs unit test suites written
using the `scalatest` library. It may depend on `scala_library`,
`scala_macro_library` and `java_library` rules.

A `scala_test` by default runs all tests in a given target.
For backwards compatibility it accepts a `suites` attribute which
is ignored due to the ease with which that field is not correctly
populated and tests are not run.


<a name="scala_repl"></a>
## scala_repl
```python
scala_repl(name, deps, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags, unused_dependency_checker_mode)
```
A scala repl allows you to add library dependencies (not currently `scala_binary` targets)
to generate a script to run which starts a REPL.
Since `bazel run` closes stdin, it cannot be used to start the REPL. Instead,
you use `bazel build` to build the script, then run that script as normal to start a REPL
session. An example in this repo:
```
bazel build test:HelloLibRepl
bazel-bin/test/HelloLibRepl
```

<a name="scala_library_suite"></a>
## scala_library_suite

The scala library suite allows you to define a glob or series of targets to generate sub
scala libraries for. The outer target will export all of the inner targets. This allows splitting up
of a series of independent files in a larger target into smaller ones. This lets us cache outputs better
and also build the individual targets in parallel. Downstream targets should not be aware of its presence.

<a name="scala_test_suite"></a>
## scala\_test_suite

The scala test suite allows you to define a glob or series of targets to generate sub
scala tests for. The outer target defines a native test suite to run all the inner tests. This allows splitting up
of a series of independent tests from one target into several. This lets us cache outputs better
and also build and test the individual targets in parallel.

<a name="thrift_library"></a>
## thrift_library

```python
load("@io_bazel_rules_scala//thrift:thrift.bzl", "thrift_library")
thrift_library(name, srcs, deps, absolute_prefix, absolute_prefixes)
```

`thrift_library` generates a thrift source zip file. It should be consumed by a thrift compiler like `scrooge_scala_library` (in its `deps`).

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <p><code>Name, required</code></p>
        <p>A unique name for this target</p>
      </td>
    </tr>
      <td><code>srcs</code></td>
      <td>
        <p><code>List of labels, required</code></p>
        <p>List of Thrift <code>.thrift</code> source files used to build the target</p>
      </td>
    </tr>
    <tr>
      <td><code>deps</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of other thrift dependencies that this thrift depends on.  Also can include `scroogle_scala_import`
        targets, containing additional `thrift_jars` (which will be compiled) and/or `scala_jars` needed at compile time (such as Finagle).</p>
      </td>
    </tr>
    <tr>
      <td><code>absolute_prefix</code></td>
      <td>
        <p><code>string; optional (deprecated in favor of absolute_prefixes)</code></p>
        <p>This string acts as a wildcard expression of the form *`string_value` that is removed from the start of the path.
        Example: thrift is at `a/b/c/d/e/A.thrift` , prefix of `b/c/d`. Will mean other thrift targets can refer to this thrift
        at `e/A.thrift`.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>absolute_prefixes</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>Each of these strings acts as a wildcard expression of the form <code>*string_value</code> that is removed from the start of the path.
        Example: thrift is at <code>a/b/c/d/e/A.thrift</code> , prefix of <code>b/c/d</code>. Will mean other thrift targets can refer to this thrift
        at <code>e/A.thrift</code>. Exactly one of these must match all thrift paths within the target, more than one or zero will fail the build.
        The main use case to have several here is to make a macro target you can share across several indvidual <code>thrift_library</code>, if source path is
        <code>/src/thrift</code> or <code>/src/main/thrift</code> it can strip off the prefix without users needing to configure it per target.
        </p>
      </td>
    </tr>
  </tbody>
</table>

<a name="scalapb_proto_library"></a>
## scalapb\_proto_library

You first need to add the following to your WORKSPACE file:

```python
load("@io_bazel_rules_scala//scala_proto:scala_proto.bzl", "scala_proto_repositories")
scala_proto_repositories()
```

Then you can import `scalapb_proto_library` in any BUILD file like this:

```python
load("@io_bazel_rules_scala//scala_proto:scala_proto.bzl", "scalapb_proto_library")
scalapb_proto_library(name, deps, with_grpc, with_java, with_flat_package, with_single_line_to_string)
```

`scalapb_proto_library` generates a scala library of scala proto bindings
generated by the [ScalaPB compiler](https://github.com/scalapb/ScalaPB).

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <p><code>Name, required</code></p>
        <p>A unique name for this target</p>
      </td>
    <tr>
      <td><code>deps</code></td>
      <td>
        <p><code>List of labels, required</code></p>
        <p>List of dependencies for this target. Must either be of type <code>proto_library</code> or <code>java_proto_library</code> (allowed only if <code>with_java</code> is enabled) </p>
      </td>
    </tr>
    <tr>
      <td><code>with_grpc</code></td>
      <td>
        <p><code>boolean; optional (default False)</code></p>
        <p>Enables generation of grpc service bindings for services defined in <code>deps</code></p>
      </td>
    </tr>
    <tr>
      <td><code>with_java</code></td>
      <td>
        <p><code>boolean; optional (default False)</code></p>
        <p>Enables generation of converters to and from java protobuf bindings. If you set this to <code>True</code> make sure that you pass the corresponding <code>java_proto_library</code> target in <code>deps</code></p>
      </td>
    </tr>
    <tr>
      <td><code>with_flat_package</code></td>
      <td>
        <p><code>boolean; optional (default False)</code></p>
        <p>When true, ScalaPB will not append the protofile base name to the package name</p>
      </td>
    </tr>
    <tr>
      <td><code>with_single_line_to_string</code></td>
      <td>
        <p><code>boolean; optional (default False)</code></p>
        <p>Enables generation of <code>toString()</code> methods that use the single line format</p>
      </td>
    </tr>
  </tbody>
</table>

## scala_toolchain
Scala toolchain allows you to define global configuration to all scala targets.
Currently the only option that can be set is `scalacopts` but the plan is to expand it to other options as well.

**some scala_toolchain must be registered!**
### Several options to configure scala_toolchain:
#### A) Use default scala_toolchain:
In your workspace file add the following lines:
  ```python
  # WORKSPACE
  # register default scala toolchain
  load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
  scala_register_toolchains()
  ```
#### B) Defining your own scala_toolchain requires 2 steps:
1. Add your own definition to scala_toolchain to a `BUILD` file:
  ```python
  # //toolchains/BUILD
  load("//scala:scala_toolchain.bzl", "scala_toolchain")

  scala_toolchain(
      name = "my_toolchain_impl",
      scalacopts = ["-Ywarn-unused"],
      unused_dependency_checker_mode = "off",
      visibility = ["//visibility:public"]
  )

  toolchain(
      name = "my_scala_toolchain",
      toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
      toolchain = "my_toolchain_impl",
      visibility = ["//visibility:public"]
  )
  ```
2. register your custom toolchain from `WORKSPACE`:
  ```python
  # WORKSPACE
  # ...
  register_toolchains("//toolchains:my_scala_toolchain")
  ```

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

* [Etsy](https://www.etsy.com/)
* [Kitty Hawk](https://kittyhawk.aero/)
* [Meetup](https://meetup.com/)
* [Spotify](https://www.spotify.com/)
* [Stripe](https://stripe.com/)
* [VSCO](https://vsco.co)
* [Wix](https://www.wix.com/)

