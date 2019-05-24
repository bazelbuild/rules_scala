# scala_macro_library

```python
scala_macro_library(
    name,
    srcs,
    deps,
    runtime_deps,
    exports,
    data,
    main_class,
    resources,
    resource_strip_prefix,
    scalacopts,
    jvm_flags,
    scalac_jvm_flags,
    javac_jvm_flags,
    unused_dependency_checker_mode
)
```

`scala_macro_library` generates a `.jar` file from `.scala` source files when
they contain macros. For macros, there are no interface jars because the macro
code is executed at compile time. For best performance, aim for granular (smaller)
targets to take advantage of Bazel caching as much as possible.

In order to have a Java rule use this jar file, use the `java_import` rule.

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