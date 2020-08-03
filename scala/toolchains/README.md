# Developing Toolchains for Deps

## Motivation and design patterns

Toolchains add extra layer of indirection to configure your rules. Toolchains can be used to provide 
deps required for tool (eg. compiler) without hardcoding labels. Users can define toolchains by 
using labels from their chosen loaders. This type of indirections allows to configure rules_scala 
without using [problematic](https://github.com/bazelbuild/bazel/issues/1952) bind. 

### Patterns
## Dependency providers on toolchains for toolchain aware rules

This is a default pattern and should be considered first when designing rules. This is a
recommended pattern, when a rule implementation knows how to consume information from a toolchain.
 
Dependencies are configured as a list of provider target labels on the toolchain. Toolchain
aware rules will lookup providers by their ids. It is important for rule developers to take into
account good reporting when users misconfigure provider mappings. Example of dependency providers 
configuration:
```starlark
   dep_providers = [
       ":my_compile_deps_provider",
       ":my_runtime_deps_provider",
   ]
```

Dep providers are instances of DepInfo. Make sure to load them using absolute name including 
external repository name (otherwise they may be treated as different):
```starlark 
load("@io_bazel_rules_scala//scala:providers.bzl", "DepsInfo")
```

`DepsInfo` provider targets can be declared using rule `declare_deps_provider`:
```starlark
load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")

declare_deps_provider(
    name = "my_compile_deps_provider",
    deps_id = "runtime_deps"
    visibility = ["//visibility:public"],
    deps = [
        "@com_lihaoyi_fastparse_2_12",
        "@com_thesamet_scalapb_lenses_2_12",
        "@io_grpc_grpc_protobuf",
        "@org_scala_lang_scala_library",
    ],
)
```
`deps_id` is an id used by rules to lookup for dep list defined by `DepsInfo` provider. Each rule
may define their own ids.

Toolchain can be declared using rule `declare_deps_toolchain` and then wired with a `toolchain_type`
using `toolchain`:
```starlark
load("@io_bazel_rules_scala//scala/toolchains:toolchains.bzl", "declare_deps_toolchain")

declare_deps_toolchain(
    name = "my_deps_toolchain_impl",
    dep_providers = [
        ":my_compile_deps_provider",
        ":my_runtime_deps_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "my_deps_toolchain",
    toolchain = ":my_deps_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//my_rules/toolchain:my_toolchain_type",
    visibility = ["//visibility:public"],
)
```

## Rules to export deps as targets to be depended on by other rules not aware of toolchains

This pattern is used to pass dependencies to rules, which are not aware of particular toolchain. For
example, Scala compile classpath deps which are defined on Scala toolchains can be made available to 
non scala rules by creating a toolchain aware rule to export deps. This pattern exports dependencies 
from the toolchain defined by the previous pattern. This pattern introduces additional complexity 
and only needs to be used when the regular toolchain consumption is not sufficient. This pattern 
should be used only for internal implementation needs. 

### Exporting deps via toolchains

To define toolchain deps with deps exporting, the following steps need to be taken:
1. Create rule exposing toolchain deps using infra helper `expose_toolchain_deps`
```starlark
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

def _toolchain_deps(ctx):
    toolchain_type_label = "@io_bazel_rules_scala//my_rules/toolchain:my_toolchain_type"
    return expose_toolchain_deps(ctx, toolchain_type_label)

my_toolchain_deps = rule(
    implementation = _toolchain_deps,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = ["@io_bazel_rules_scala//my_rules/toolchain:my_toolchain_type"],
)
```

2. Declare dependency exporting targets

```starlark 
my_toolchain_deps(
    name = "my_deps",
    deps_id = "my_compile_deps_provider",
)
```


## Reusable infra code to define toolchains for dependencies

### Reusable symbols
- provider `DepsInfo` - provider with a field `deps`, which contains dep list to be provided via 
toolchain

- rule `declare_deps_provider` - used to declare target with `DepsProvider`. Eg.:
```starlark
declare_deps_provider(
    name = "my_runtime_deps_provider",
    deps_id = "runtime_deps"
    deps = ["@dep1", "@dep2"],
    visibility = ["//visibility:public"],
)
```
- rule `declare_deps_toolchain` - used to declare toolchains for deps providers. Eg.:
```starlark
declare_deps_toolchain(
    name = "my_toolchain_impl",
    dep_providers = [
        ":my_compile_deps_provider",
        ":my_runtime_deps_provider",
    ],
    visibility = ["//visibility:public"],
)
```

Attribute `dep_providers` is a list of DepInfo targets used for indirection in toolchain exporting 
rules.  

- `def expose_toolchain_deps(ctx, toolchain_type_label)` - helper to export deps from a toolchain. 
Intended to be used when defining toolchain deps exporting rules. Eg.:
```starlark
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

def _toolchain_deps(ctx):
    toolchain_type_label = "@io_bazel_rules_scala//my_rules/toolchain:my_toolchain_type"
    return expose_toolchain_deps(ctx, toolchain_type_label)

my_toolchain_deps = rule(
    implementation = _toolchain_deps,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = ["@io_bazel_rules_scala//my_rules/toolchain:my_toolchain_type"],
)
```
