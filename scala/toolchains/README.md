# Toolchains for Deps

## Motivation and design patterns

Provide a way to configure rules_scala without using [problematic](https://github.com/bazelbuild/bazel/issues/1952) bind. 

### Patterns
- Dependency providers on toolchains for toolchain aware rules

This is recommended pattern, when a rule implementation knows how to consume information from a toolchain.

- Rules to export deps as targets to be depended on by other rules not aware of toolchains

This pattern is used to pass dependencies to rules, which are not aware of particular toolchain. For example, Scala 
compile classpath deps which are defined on Scala toolchains can be made available to non scala rules by creating a 
toolchain aware rule to export deps.

### Usage
Users who want to customize dependecies for a feature will have to declare deps providers and wire them up in the
 toolchain. Eg.:

```python
declare_deps_provider(
    name = "scalapb_compile_deps_provider",
    visibility = ["//visibility:public"],
    deps = [
        "@com_lihaoyi_fastparse_2_12",
        "@com_thesamet_scalapb_lenses_2_12",
        "@com_thesamet_scalapb_scalapb_runtime_2_12",
        "@io_grpc_grpc_protobuf",
        "@org_scala_lang_scala_library",
    ],
)

declare_deps_provider(
    name = "scalapb_grpc_deps_provider",
    visibility = ["//visibility:public"],
    deps = [
        "@com_google_guava_guava",
        "@com_google_instrumentation_instrumentation_api",
        "@com_lmax_disruptor",
        "@com_thesamet_scalapb_scalapb_runtime_grpc_2_12",
        "@io_grpc_grpc_api",
        "@io_grpc_grpc_context",
        "@io_grpc_grpc_core",
        "@io_grpc_grpc_netty",
        "@io_grpc_grpc_protobuf",
        "@io_grpc_grpc_stub",
        "@io_netty_netty_buffer",
        "@io_netty_netty_codec",
        "@io_netty_netty_codec_http",
        "@io_netty_netty_codec_http2",
        "@io_netty_netty_codec_socks",
        "@io_netty_netty_common",
        "@io_netty_netty_handler",
        "@io_netty_netty_handler_proxy",
        "@io_netty_netty_resolver",
        "@io_netty_netty_transport",
        "@io_opencensus_opencensus_api",
        "@io_opencensus_opencensus_contrib_grpc_metrics",
        "@io_opencensus_opencensus_impl",
        "@io_opencensus_opencensus_impl_core",
        "@io_perfmark_perfmark_api",
    ],
)

declare_deps_toolchain(
    name = "proto_deps_toolchain_impl",
    dep_providers = {
        ":scalapb_compile_deps_provider": "compile_deps",
        ":scalapb_grpc_deps_provider": "grpc_deps",
    },
    visibility = ["//visibility:public"],
)

toolchain(
    name = "proto_deps_toolchain",
    toolchain = ":proto_deps_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala_proto/toolchain:proto_toolchain_type",
    visibility = ["//visibility:public"],
)
```
## Exporting deps via toolchains

Toolchains can be used to provide dependencies indirectly. For rules which are not aware of specific toolchains, 
dependencies can be provided by adding to deps a target which knows how to export from a toolchain. Eg.:
```python
# target which exports toolchain deps from provider with ID "compile_deps"
proto_toolchain_deps(
    name = "default_scalapb_compile_dependencies",
    provider_id = "compile_deps",
    visibility = ["//visibility:public"],
)

# provider declaration
declare_deps_provider(
    name = "scalapb_grpc_deps_provider",
    deps = ["@dep1", "@dep2"],
    visibility = ["//visibility:public"],
)

# toolchain declaration:
toolchain_type(
    name = "proto_toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "proto_toolchain",
    toolchain = ":proto_toolchain_impl",
    toolchain_type = ":proto_toolchain_type",
    visibility = ["//visibility:public"],
)

declare_deps_toolchain(
    name = "proto_toolchain_impl",
    dep_providers = {
        ":scalapb_compile_deps_provider": "compile_deps",
        ":scalapb_grpc_deps_provider": "grpc_deps"
    },
    visibility = ["//visibility:public"],
)
```

To define toolchain deps with deps exporting, the follwoing steps need to be taken:
1. Declare dep providers with `declare_deps_provider`
2. Define `toolchain_type`, declare toolchain with infra helper `declare_deps_toolchain`, wire them up with `toolchain`
3. Create rule exposing toolchain deps using infra helper `expose_toolchain_deps`
4. Declare deps targets
5. Use deps targets instead of bind targets!

## Reusable infra code to define toolchains for dependencies

### Reusable symbols
- provider `DepsProvider` - provider with a field `deps`, which contains dep list to be provided via toolchain
- rule `declare_deps_provider` - used to declare target with `DepsProvider`. Eg.:
```python
declare_deps_provider(
    name = "scalapb_grpc_deps_provider",
    deps = ["@dep1", "@dep2"],
    visibility = ["//visibility:public"],
)
```
- rule `declare_deps_toolchain` - used to declare toolchains for deps providers. Eg.:
```python
declare_deps_toolchain(
    name = "proto_toolchain_impl",
    dep_providers = {
        ":scalapb_compile_deps_provider": "compile_deps",
        ":scalapb_grpc_deps_provider": "grpc_deps"
    },
    visibility = ["//visibility:public"],
)

```
Attribute `dep_providers` is maps dep provider label to an id used for indirection in toolchain exporting rules 

- `def expose_toolchain_deps(ctx, toolchain_type_label)` - helper to export export deps from toolchain. Intended to be 
used when defining toolchain deps exporting rules. Eg.:
```python
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

def _toolchain_deps(ctx):
    toolchain_type_label = "@io_bazel_rules_scala//scala_proto/toolchain:proto_toolchain_type"
    return expose_toolchain_deps(ctx, toolchain_type_label)

proto_toolchain_deps = rule(
    implementation = _toolchain_deps,
    attrs = {
        "provider_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = ["@io_bazel_rules_scala//scala_proto/toolchain:proto_toolchain_type"],
)
```
