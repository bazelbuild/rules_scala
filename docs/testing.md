## Testing toolchain configuration

Toolchain type `testing_toolchain_type` is used to set up test dependencies. 

### Example to set up JUnit dependencies

`BUILD` file content in your prefered package:
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

Toolchain must be registerd in your `WORKSPACE` file: 
```starlark
register_toolchains('//my/package:testing_toolchain')
```

