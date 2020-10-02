## Testing toolchain configuration

Toolchain type `testing_toolchain_type` is used to set up test dependencies. You can customize
test dependencies by defining a custom testing toolchain.

In your `WORKSPACE` default repositories and toolchains can be loaded via:
```starlark
# JUnit 4
load("@io_bazel_rules_scala//testing:junit.bzl", "junit_repositories", "junit_toolchain")
junit_repositories()
junit_toolchain()

# ScalaTest
load(""@io_bazel_rules_scala//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")
scalatest_repositories()
scalatest_toolchain()
```

### Example to set up JUnit dependencies

`BUILD` file content in your preferred package:
```starlark
load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")
load("@io_bazel_rules_scala//testing/toolchain:toolchain.bzl", "scala_testing_toolchain")

scala_testing_toolchain(
    name = "testing_toolchains_with_junit",
    dep_providers = [
        ":junit_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "testing_toolchain",
    toolchain = ":testing_toolchains_with_junit",
    toolchain_type = "@io_bazel_rules_scala//testing/toolchain:testing_toolchain_type",
    visibility = ["//visibility:public"],
)

declare_deps_provider(
    name = "junit_classpath_provider",
    deps_id = "junit_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@my_hamcrest_core",
        "@my_junit",
    ],
)
```

`junit_classpath_provider` (deps_id `junit_classpath`) is where classpath required for junit tests
is defined.

ScalaTest support can be enabled by configuring a provider with an id `scalatest_classpath`:

```starlark
scala_testing_toolchain(
    name = "testing_toolchains_with_scalatest",
    dep_providers = [
        ":scalatest_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "testing_toolchain",
    toolchain = ":testing_toolchains_with_scalatest",
    toolchain_type = "@io_bazel_rules_scala//testing/toolchain:testing_toolchain_type",
    visibility = ["//visibility:public"],
)

declare_deps_provider(
    name = "scalatest_classpath_provider",
    deps_id = "junit_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@scalactic",
        "@scalatest",
    ],
)
```

Toolchain must be registered in your `WORKSPACE` file: 
```starlark
register_toolchains('//my/package:testing_toolchain')
```

Single toolchain can be used to configure multiple testing rules (JUnit 4, ScalaTest).
