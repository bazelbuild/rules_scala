# Scala Rules for Bazel
[![Build Status](https://travis-ci.org/bazelbuild/rules_scala.svg?branch=master)](https://travis-ci.org/bazelbuild/rules_scala)

<div class="toc">
  <h2>Rules</h2>
  <ul>
    <li><a href="#scala_library">scala_library/scala_macro_library</a></li>
    <li><a href="#scala_binary">scala_binary</a></li>
    <li><a href="#scala_test">scala_test</a></li>
  </ul>
</div>

## Overview

This rule is used for building [Scala][scala] projects with Bazel. There are
currently four rules, `scala_library`, `scala_macro_library`, `scala_binary`
and `scala_test`.

## Getting started

In order to use `scala_library`, `scala_macro_library`, and `scala_binary`,
you must have bazel 0.2.3 and add the following to your WORKSPACE file:

```python
git_repository(
    name = "io_bazel_rules_scala",
    remote = "https://github.com/bazelbuild/rules_scala.git",
    commit = "7b891adb975b4e3e6569b763d39ab6e9234196c9", # update this as needed
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
You may wish to have these rules loaded by default using bazel's prelude. You can add the above to the file `tools/build_rules/prelude_bazel` in your repo (don't forget to have a, possible empty, BUILD file there) and then it will be automatically prepended to every BUILD file in the workspace.

[scala]: http://www.scala-lang.org/

<a name="scala_library"></a>
## scala\_library / scala\_macro_library

```python
scala_library(name, srcs, deps, runtime_deps, exports, data, main_class, resources, scalacopts, jvm_flags)
scala_macro_library(name, srcs, deps, runtime_deps, exports, data, main_class, resources, scalacopts, jvm_flags)
```

`scala_library` generates a `.jar` file from `.scala` source files. This rule
also creates an interface jar to avoid recompiling downstream targets unless
then interface changes.

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
  </tbody>
</table>

<a name="scala_binary"></a>
## scala_binary

```python
scala_binary(name, srcs, deps, runtime_deps, data, main_class, resources, scalacopts, jvm_flags)
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
          List of JVM flags to be passed to scalac after the
          <code>scalacopts</code>. Subject to
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
scala_test(name, srcs, suites, deps, data, main_class, resources, scalacopts, jvm_flags)
```

`scala_test` generates a Scala executable which runs unit test suites written
using the `scalatest` library. It may depend on `scala_library`,
`scala_macro_library` and `java_library` rules.

A `scala_test` by default runs all tests in a given target.
For backwards compatiblity it accepts a `suites` attribute which
is ignored due to the ease with which that field is not correctly
populated and tests are not run.
