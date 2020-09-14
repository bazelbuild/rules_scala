load("//scala:providers.bzl", "declare_deps_provider")
load("//jmh/toolchain:toolchain.bzl", "export_toolchain_deps", "jmh_toolchain")

jmh_toolchain(
    name = "jmh_toolchain_impl",
    dep_providers = [":jmh_classpath_provider"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "jmh_toolchain",
    toolchain = ":jmh_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//jmh/toolchain:jmh_toolchain_type",
)

declare_deps_provider(
    name = "jmh_classpath_provider",
    deps_id = "jmh_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/jmh/net_sf_jopt_simple_jopt_simple",
        "//external:io_bazel_rules_scala/dependency/jmh/org_apache_commons_commons_math3",
    ],
)

export_toolchain_deps(
    name = "jmh_classpath",
    deps_id = "jmh_classpath",
    visibility = ["//visibility:public"],
)
