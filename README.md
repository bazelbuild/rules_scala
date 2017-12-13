# Scala Rules for Bazel
[![Build Status](https://travis-ci.org/bazelbuild/rules_scala.svg?branch=master)](https://travis-ci.org/bazelbuild/rules_scala) [![Build Status](https://ci.bazel.io/buildStatus/icon?job=rules_scala)](https://ci.bazel.io/job/rules_scala)

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

rules_scala_version="5cdae2f034581a05e23c3473613b409de5978833" # update this as needed

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

[scala]: http://www.scala-lang.org/

<a name="scala_library"></a>
## scala\_library / scala\_macro_library

```python
scala_library(name, srcs, deps, runtime_deps, exports, data, main_class, resources, resource_strip_prefix, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags)
scala_macro_library(name, srcs, deps, runtime_deps, exports, data, main_class, resources, resource_strip_prefix, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags)
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
        library</p>
      </td>
    </tr>
    <tr>
      <td><code>deps</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of other libraries to linked to this library target</p>
      </td>
    </tr>
    <tr>
      <td><code>runtime_deps</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of other libraries to put on the classpath only at runtime. This is rarely needed in Scala.</p>
      </td>
    </tr>
    <tr>
      <td><code>exports</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of targets to add to the dependencies of those that depend on this target. Similar
        to the `java_library` parameter of the same name. Use this sparingly as it weakens the
        precision of the build graph.</p>
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
  </tbody>
</table>

<a name="scala_binary"></a>
## scala_binary

```python
scala_binary(name, srcs, deps, runtime_deps, data, main_class, resources, resource_strip_prefix, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags)
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
        <p>List of other libraries to linked to this binary target</p>
      </td>
    </tr>
    <tr>
      <td><code>runtime_deps</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of other libraries to put on the classpath only at runtime. This is rarely needed in Scala.</p>
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
  </tbody>
</table>

<a name="scala_test"></a>
## scala_test

```python
scala_test(name, srcs, suites, deps, data, main_class, resources, resource_strip_prefix, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags)
```

`scala_test` generates a Scala executable which runs unit test suites written
using the `scalatest` library. It may depend on `scala_library`,
`scala_macro_library` and `java_library` rules.

A `scala_test` by default runs all tests in a given target.
For backwards compatiblity it accepts a `suites` attribute which
is ignored due to the ease with which that field is not correctly
populated and tests are not run.


<a name="scala_repl"></a>
## scala_repl
```python
scala_repl(name, deps, scalacopts, jvm_flags, scalac_jvm_flags, javac_jvm_flags)
```
A scala repl allows you to add library dependendencies (not currently `scala_binary` targets)
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
and also build the indvidual targets in parallel. Downstream targets should not be aware of its presence.

<a name="scala_test_suite"></a>
## scala\_test_suite

The scala test suite allows you to define a glob or series of targets to generate sub
scala tests for. The outer target defines a native test suite to run all the inner tests. This allows splitting up
of a series of independent tests from one target into several. This lets us cache outputs better
and also build and test the indvidual targets in parallel.

<a name="thrift_library"></a>
## thrift_library

```python
load("@io_bazel_rules_scala//thrift:thrift.bzl", "thrift_library")
thrift_library(name, srcs, deps, absolute_prefix, absolute_prefixes)
```

`thrift_library` generates a thrift source zip file. It should be consumed by a thrift compiler like `scrooge_scala_library`.

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
        <p>List of other thrift dependencies that this thrift depends on.</p>
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

## [Experimental] Using strict-deps
Bazel pushes towards explicit and minimial dependencies to keep BUILD file higene and allow for targets to refactor their dependencies without fear of downstream breaking.    
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

## Building from source
Test & Build:
```
bash test_run.sh
```
This doesn't currently pass on OS X (see #136 for details) and so you can also use:

```
bazel test //test/...
```
Note `bazel test //...` will not work since we have a sub-folder on the root folder which is meant to be used in a failure scenario in the integration tests.
Similarly to only build you should use `bazel build //src/...` due to that folder.
