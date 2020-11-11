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
load("@io_bazel_rules_scala//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")
scalatest_repositories()
scalatest_toolchain()

# Specs2 with Junit
load("@io_bazel_rules_scala//testing:specs2_junit.bzl", "specs2_junit_repositories", "specs2_junit_toolchain")
specs2_junit_repositories()
specs2_junit_toolchain()
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

Specs2 with Junit support can be enabled by configuring providers with ``, ``, `` ids:
```starlark
scala_testing_toolchain(
    name = "specs2_junit_toolchain_impl",
    dep_providers = [
        ":junit_classpath_provider",
        ":specs2_classpath_provider",
        ":specs2_junit_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "specs2_junit_toolchain",
    toolchain = ":specs2_junit_toolchain_impl",
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

declare_deps_provider(
    name = "specs2_classpath_provider",
    deps_id = "specs2_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@my_specs2_common",
        "@my_specs2_core",
        "@my_specs2_fp",
        "@my_specs2_matcher",
    ],
)

declare_deps_provider(
    name = "specs2_junit_classpath_provider",
    deps_id = "specs2_junit_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@my_specs2_junit",
    ],
)
```


Toolchain must be registered in your `WORKSPACE` file: 
```starlark
register_toolchains('//my/package:testing_toolchain')
```

Single toolchain can be used to configure multiple testing rules (JUnit 4, ScalaTest, Specs2 with Junit). 
Default repositories and toolchains in your `WORKSPACE` can be loaded via:
```starlark
# JUnit 4
load("//testing:junit.bzl", "junit_repositories", "junit_toolchain")
junit_repositories()
junit_toolchain()

# ScalaTest
load("//testing:scalatest.bzl", "scalatest_repositories", "scalatest_toolchain")
scalatest_repositories()
scalatest_toolchain()

# Specs2 JUnit runner
load("//testing:specs2_junit.bzl", "specs2_junit_repositories", "specs2_junit_toolchain")
specs2_junit_repositories()
specs2_junit_toolchain()
```

