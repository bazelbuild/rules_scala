load(":toolchain_deps.bzl", "testing_toolchain_deps")
load("//testing:testing.bzl", "DEP_PROVIDERS")

toolchain_type(
    name = "testing_toolchain_type",
    visibility = ["//visibility:public"],
)

[
    testing_toolchain_deps(
        name = dep,
        deps_id = dep,
        visibility = ["//visibility:public"],
    )
    for dep in DEP_PROVIDERS
]
