load("//jmh/toolchain:toolchain.bzl", "DEP_PROVIDERS", "export_toolchain_deps")

[
    export_toolchain_deps(
        name = provider,
        deps_id = provider,
        visibility = ["//visibility:public"],
    )
    for provider in DEP_PROVIDERS
]
