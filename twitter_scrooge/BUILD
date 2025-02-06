load(
    "//twitter_scrooge/toolchain:toolchain.bzl",
    "DEP_PROVIDERS",
    "export_scrooge_deps",
)

[
    export_scrooge_deps(
        name = dep,
        deps_id = dep,
        visibility = ["//visibility:public"],
    )
    for dep in DEP_PROVIDERS
]
