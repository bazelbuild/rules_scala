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

### Configuring testing dependencies via toolchain

Default dependencies, which come preconfigured with Rules Scala repositories are mostly tailored 
towards supporting Rules Scala codebase, and may miss specific versions or libraries for your 
usecase. You should prefer configuring dependencies via toolchains.

Test framework dependencies are configured via testing toolchain. For convenience, macro
`setup_scala_testing_toolchain` can be used to define such toolchains.

```starlark
load(
    "@io_bazel_rules_scala//testing:testing.bzl",
    "setup_scala_testing_toolchain",
)
```

Attributes

- `name` - toolchain name
- `visibility` - optional, default value is `["//visibility:public"]`
- `scalatest_classpath` - List of ScalaTest deps, can be omitted if ScalaTest rules won't be used.
- `junit_classpath` - List of Junit 4 deps, required for Specs2 and JUnit rules support. Otherwise,
  can
  be omitted.
- `specs2_classpath` - List of Specs2 deps, requires `specs2_junit_classpath` and `junit_classpath`
  to be provided alongside.
- `specs2_junit_classpath` - Specs2 JUnit runner dep, required for Specs2 rules as the use JUnit
  runner.

Examples (assumes maven deps are managed with rules_jvm_external):

#### ScalaTest (flat spec with must matchers)

```starlark
# BUILD
load(
    "@io_bazel_rules_scala//testing:testing.bzl",
    "setup_scala_testing_toolchain",
)

setup_scala_testing_toolchain(
    name = "scalatest_toolchain",
    scalatest_classpath = [ 
       "@maven//:org_scalactic_scalactic_2_13",
       "@maven//:org_scalatest_scalatest_2_13",
       "@maven//:org_scalatest_scalatest_compatible",
       "@maven//:org_scalatest_scalatest_core_2_13",
       "@maven//:org_scalatest_scalatest_flatspec_2_13",
       "@maven//:org_scalatest_scalatest_matchers_core_2_13",
       "@maven//:org_scalatest_scalatest_mustmatchers_2_13",
    ],
)
```
Register the toolchain
```starlark
# WORKSPACE
register_toolchains('//:scalatest_toolchain')
```

#### JUnit 4
```starlark
# BUILD
load(
    "@io_bazel_rules_scala//testing:testing.bzl",
    "setup_scala_testing_toolchain",
)

setup_scala_testing_toolchain(
    name = "junit_toolchain",
    junit_classpath = [
        "@maven//:junit_junit",
        "@maven//:org_hamcrest_hamcrest_core",
    ],
)
```
Register the toolchain
```starlark
# WORKSPACE
register_toolchains('//:junit_toolchain')
```

#### Specs2
For Specs2 rules to work, `junit_classpath`, `specs2_junit_classpath` and `specs2_classpath` must
be configured.
```starlark
# BUILD
load(
    "@io_bazel_rules_scala//testing:testing.bzl",
    "setup_scala_testing_toolchain",
)

setup_scala_testing_toolchain(
    name = "specs2_toolchain",
    junit_classpath = [
        "@maven//:junit_junit",
        "@maven//:org_hamcrest_hamcrest_core",
    ],
    specs2_junit_classpath = [
        "@maven//:org_specs2_specs2_junit_2_12",
    ],
    specs2_classpath = [
        "@maven//:org_specs2_specs2_common_2_12",
        "@maven//:org_specs2_specs2_core_2_12",
        "@maven//:org_specs2_specs2_fp_2_12",
        "@maven//:org_specs2_specs2_junit_2_12",
        "@maven//:org_specs2_specs2_matcher_2_12",
    ]
)        
```
Register the toolchain
```starlark
# WORKSPACE
register_toolchains('//:specs2_toolchain')
```
