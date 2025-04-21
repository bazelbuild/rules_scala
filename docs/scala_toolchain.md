# scala_toolchain

`scala_toolchain` allows you to define the global configuration for all Scala
targets.

**Some `scala_toolchain` must be registered!**

## Options to configure `scala_toolchain`

### A) Use the builtin Scala toolchain via `scala_toolchains`

Add the following lines to `WORKSPACE`:

```py
# WORKSPACE
# register default scala toolchain
load(
    "@rules_scala//scala:toolchains.bzl",
    "scala_register_toolchains",
    "scala_toolchains",
)

scala_toolchains()

scala_register_toolchains()
```

### B) Defining your own `scala_toolchain`

#### Step 1

You can add your own `scala_toolchain` definition to a `BUILD` file in one of
two ways. If you only want to set different [configuration
options](#configuration-options), but rely on the builtin toolchain JARs, use
`scala_toolchain` directly. This example is inspired by [`BUILD.bazel` from michalbogacz/scala-bazel-monorepo/](
https://github.com/michalbogacz/scala-bazel-monorepo/blob/2cac860f386dcaa1c3be56cd25a84b247d335743/BUILD.bazel)):

```py
load("@rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "my_toolchain_impl",
    scalacopts = [
        "-Wunused:all",
    ],
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "warn",
)

toolchain(
    name = "my_toolchain",
    toolchain = ":my_toolchain_impl",
    toolchain_type = "@rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)
```

If you want to use your own compiler JARs, use `setup_scala_toolchain()`
instead. This example assumes the external libraries are resolved with
[rules_jvm_external](https://github.com/bazelbuild/rules_jvm_external):

```py
# //toolchains/BUILD
load("@rules_scala//scala:scala.bzl", "setup_scala_toolchain")

setup_scala_toolchain(
    name = "my_toolchain",
    # configure toolchain dependencies
    parser_combinators_deps = [
        "@maven//:org_scala_lang_modules_scala_parser_combinators_2_12",
    ],
    scala_compile_classpath = [
        "@maven//:org_scala_lang_scala_compiler",
        "@maven//:org_scala_lang_scala_library",
        "@maven//:org_scala_lang_scala_reflect",
    ],
    scala_library_classpath = [
        "@maven//:org_scala_lang_scala_library",
        "@maven//:org_scala_lang_scala_reflect",
    ],
    scala_macro_classpath = [
        "@maven//:org_scala_lang_scala_library",
        "@maven//:org_scala_lang_scala_reflect",
    ],
    scala_xml_deps = [
        "@maven//:org_scala_lang_modules_scala_xml_2_12",
    ],
    # example of setting attribute values
    scalacopts = ["-Ywarn-unused"],
    unused_dependency_checker_mode = "off",
    visibility = ["//visibility:public"]
)
```

#### Step 2

Register your custom toolchain:

```py
# MODULE.bazel or WORKSPACE
register_toolchains("//toolchains:my_scala_toolchain")
```

#### Step 3 (optional)

When using your own JARs for every `setup_scala_toolchain()` argument, while
using `scala_deps` or`scala_toolchains()` to instantiate other builtin
toolchains:

- Bzlmod: Don't instantiate `scala_deps.scala()`.
- `WORKSPACE`: Call `scala_toolchains(scala = False, ...)`.

Otherwise, `scala_deps` or `scala_toolchains()` will try to instantiate a
default Scala toolchain and its compiler JAR repositories. The build will then
fail if the configured Scala version doesn't match the `scala_version` value in
the corresponding `third_party/repositories/scala_*.bzl` file.

If you don't specify your own jars for every `setup_scala_toolchain()` argument,
set `validate_scala_version = False` to disable the Scala version check.

```py
# MODULE.bazel
scala_deps.settings(
    validate_scala_version = False,
    # ...other toolchain parameters...
)

# WORKSPACE
scala_toolchains(
    validate_scala_version = False,
    # ...other toolchain parameters...
)
```

## Configuration options

The following attributes apply to both `scala_toolchain` and
`setup_scala_toolchain`.

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
      <td><code>dep_providers</code></td>
      <td>
        <p><code>List of labels; optional</code></p>
        <p>
          Allows to configure dependencies lists by configuring <code>DepInfo</code> provider targets.
          Currently supported dep ids: <code>scala_compile_classpath</code>,
          <code>scala_library_classpath</code>, <code>scala_macro_classpath</code>, <code>scala_xml</code>,
          <code>parser_combinators</code>,
          <code>semanticdb</code>
        </p>
      </td>
    </tr>
    <tr>
      <td><code>scalacopts</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          Extra compiler options for this binary to be passed to scalac.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>scalac_jvm_flags</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          List of JVM flags to be passed to scalac. For example <code>["-Xmx5G"]</code> could be passed to control memory usage of Scalac.
        </p>
        <p>
          This is overridden by the <code>scalac_jvm_flags</code> attribute on individual targets.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>scala_test_jvm_flags</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>
          List of JVM flags to be passed to the ScalaTest runner. For example <code>["-Xmx5G"]</code> could be passed to control memory usage of the ScalaTest runner.
        </p>
        <p>
          This is overridden by the <code>jvm_flags</code> attribute on individual targets.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>unused_dependency_checker_mode</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>
          Enable unused dependency checking (see <a href="./dependency-tracking.md#experimental-unused-dependency-checking">Unused dependency checking</a>).
          Possible values are: <code>off</code>, <code>warn</code> and <code>error</code>.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>dependency_tracking_strict_deps_patterns</code></td>
      <td>
        <p><code>List of Strings; optional</code></p>
        <p>
          List of target prefixes included for strict deps analysis. Exclude patetrns with '-'
        </p>
      </td>
    </tr>
    <tr>
      <td><code>dependency_tracking_unused_deps_patterns</code></td>
      <td>
        <p><code>List of Strings; optional</code></p>
        <p>
          List of target prefixes included for unused deps analysis. Exclude patetrns with '-'
        </p>
      </td>
    </tr>
        <tr>
      <td><code>enable_semanticdb</code></td>
      <td>
        <p><code>Boolean; optional (default False)</code></p>
        <p>
          Enables semanticdb output.
        </p>
      </td>
    </tr>
            <tr>
      <td><code>semanticdb_bundle_in_jar</code></td>
      <td>
        <p><code>Boolean; optional (default False)</code></p>
        <p>
          When False, *.semanticdb files are added to the filesystem in a directory.
        </p>
        <p>
          When True, *.semanticdb files will be bundled inside the jar file.
        </p>
      </td>
    </tr>
  </tbody>
</table>
