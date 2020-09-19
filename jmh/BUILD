load("//scala:providers.bzl", "declare_deps_provider")
load("//jmh/toolchain:toolchain.bzl", "export_toolchain_deps", "jmh_toolchain")

jmh_toolchain(
    name = "jmh_toolchain_impl",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "jmh_toolchain",
    toolchain = ":jmh_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//jmh/toolchain:jmh_toolchain_type",
)

declare_deps_provider(
    name = "jmh_core_provider",
    deps_id = "jmh_core",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/jmh/jmh_core",
    ],
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

declare_deps_provider(
    name = "benchmark_generator_provider",
    deps_id = "benchmark_generator",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/jmh/jmh_core",
        "//external:io_bazel_rules_scala/dependency/jmh/jmh_generator_asm",
        "//external:io_bazel_rules_scala/dependency/jmh/jmh_generator_reflection",
        "//src/java/io/bazel/rulesscala/jar",
    ],
)

declare_deps_provider(
    name = "benchmark_generator_runtime_provider",
    deps_id = "benchmark_generator_runtime",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/jmh/org_ows2_asm_asm",
    ],
)

export_toolchain_deps(
    name = "jmh_classpath",
    deps_id = "jmh_classpath",
    visibility = ["//visibility:public"],
)

export_toolchain_deps(
    name = "jmh_core",
    deps_id = "jmh_core",
    visibility = ["//visibility:public"],
)

export_toolchain_deps(
    name = "benchmark_generator",
    deps_id = "benchmark_generator",
    visibility = ["//visibility:public"],
)

export_toolchain_deps(
    name = "benchmark_generator_runtime",
    deps_id = "benchmark_generator_runtime",
    visibility = ["//visibility:public"],
)
