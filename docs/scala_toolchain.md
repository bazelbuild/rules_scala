# scala_toolchain

`scala_toolchain` allows you to define global configuration to all Scala targets.

**Some scala_toolchain must be registered!**

### Several options to configure `scala_toolchain`:

#### A) Use the default `scala_toolchain`:

In your workspace file add the following lines:

```python
# WORKSPACE
# register default scala toolchain
load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
scala_register_toolchains()
```

#### B) Defining your own `scala_toolchain` requires 2 steps:

1. Add your own definition of `scala_toolchain` to a `BUILD` file:
    ```python
    # //toolchains/BUILD
    load("@io_bazel_rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")
    load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")

    scala_toolchain(
        name = "my_toolchain_impl",
        dep_providers = [
            ":my_scala_compile_classpath_provider",
            ":my_scala_library_classpath_provider",
            ":my_scala_macro_classpath_provider",
            ":my_scala_xml_provider",
            ":my_parser_combinators_provider",
        ],
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
   
    declare_deps_provider(
        name = "my_scala_compile_classpath_provider",
        deps_id = "scala_compile_classpath",
        visibility = ["//visibility:public"],
        deps = [
            "@io_bazel_rules_scala_scala_compiler",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    )
    
    declare_deps_provider(
        name = "my_scala_library_classpath_provider",
        deps_id = "scala_library_classpath",
        deps = [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    )
    
    declare_deps_provider(
        name = "my_scala_macro_classpath_provider",
        deps_id = "scala_macro_classpath",
        deps = [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    )
     
    declare_deps_provider(
        name = "my_scala_xml_provider",
        deps_id = "scala_xml",
        deps = ["@scala_xml_dep"],
    )
    
    declare_deps_provider(
        name = "my_parser_combinators_provider",
        deps_id = "parser_combinators",
        deps = ["@parser_combinators_dep"],
    )
    ```

2. Register your custom toolchain from `WORKSPACE`:
    ```python
    # WORKSPACE
    register_toolchains("//toolchains:my_scala_toolchain")
    ```

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
          Currently supported depset ids: <code>scala_compile_classpath</code>, 
          <code>scala_library_classpath</code>, <code>scala_macro_classpath</code>, <code>scala_xml</code>, 
          <code>parser_combinators</code>.     
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
          Enable unused dependency checking (see <a href="https://github.com/bazelbuild/rules_scala#experimental-unused-dependency-checking">Unused dependency checking</a>).
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
  </tbody>
</table>
