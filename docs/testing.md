# Testing toolchain configuration

Toolchain type `testing_toolchain_type` is used to set up test dependencies. You can customize
test dependencies by defining a custom testing toolchain.

Builtin repositories and toolchains can be loaded via:

```py
# MODULE.bazel
scala_deps = use_extension(
    "@rules_scala//scala/extensions:deps.bzl",
    "scala_deps",
)
scala_deps.scala()      # Ensure builtin Scala toolchain deps are visible
scala_deps.junit()      # JUnit 4
scala_deps.scalatest()  # ScalaTest
scala_deps.specs2()     # Specs2 with JUnit

# legacy WORKSPACE
load(
    "@rules_scala//scala:toolchains.bzl",
    "scala_register_toolchains",
    "scala_toolchains",
)

scala_toolchains(
    junit = True,      # JUnit 4
    scalatest = True,  # ScalaTest
    specs2 = True,     # Specs2 with JUnit
)

scala_register_toolchains()
```

## Configuring testing dependencies via toolchain

Default dependencies, which come preconfigured with Rules Scala repositories are mostly tailored
towards supporting Rules Scala codebase, and may miss specific versions or libraries for your
usecase. You should prefer configuring dependencies via toolchains.

Test framework dependencies are configured via testing toolchain. For convenience, macro
`setup_scala_testing_toolchain` can be used to define such toolchains.

```py
load("@rules_scala//testing:testing.bzl", "setup_scala_testing_toolchain")
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

### ScalaTest (flat spec with must matchers)

```py
# BUILD
load("@rules_scala//testing:testing.bzl", "setup_scala_testing_toolchain")

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

```py
# WORKSPACE
register_toolchains('//:scalatest_toolchain')
```

### JUnit 4

```py
# BUILD
load("@rules_scala//testing:testing.bzl", "setup_scala_testing_toolchain")

setup_scala_testing_toolchain(
    name = "junit_toolchain",
    junit_classpath = [
        "@maven//:junit_junit",
        "@maven//:org_hamcrest_hamcrest_core",
    ],
)
```

Register the toolchain

```py
# WORKSPACE
register_toolchains('//:junit_toolchain')
```

### Specs2

For Specs2 rules to work, `junit_classpath`, `specs2_junit_classpath` and `specs2_classpath` must
be configured.

```py
# BUILD
load("@rules_scala//testing:testing.bzl", "setup_scala_testing_toolchain")

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

```py
# WORKSPACE
register_toolchains('//:specs2_toolchain')
```
