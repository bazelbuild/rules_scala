load("//twitter_scrooge/toolchain:toolchain.bzl", "export_scrooge_deps", "scrooge_toolchain")
load("//scala:providers.bzl", "declare_deps_provider")

scrooge_toolchain(
    name = "scrooge_toolchain_impl",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "scrooge_toolchain",
    toolchain = ":scrooge_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//twitter_scrooge/toolchain:scrooge_toolchain_type",
    visibility = ["//visibility:public"],
)

declare_deps_provider(
    name = "aspect_compile_classpath_provider",
    deps_id = "aspect_compile_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/thrift/javax_annotation_api",
        "//external:io_bazel_rules_scala/dependency/thrift/libthrift",
        "//external:io_bazel_rules_scala/dependency/thrift/scrooge_core",
        "//external:io_bazel_rules_scala/dependency/thrift/util_core",
        "//scala/private/toolchain_deps:scala_library_classpath",
    ],
)

declare_deps_provider(
    name = "compile_classpath_provider",
    deps_id = "compile_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/thrift/libthrift",
        "//external:io_bazel_rules_scala/dependency/thrift/scrooge_core",
        "//scala/private/toolchain_deps:scala_library_classpath",
    ],
)

declare_deps_provider(
    name = "scrooge_generator_classpath_provider",
    deps_id = "scrooge_generator_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
    ],
)

declare_deps_provider(
    name = "compiler_classpath_provider",
    deps_id = "compiler_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
        "//external:io_bazel_rules_scala/dependency/thrift/util_core",
        "//external:io_bazel_rules_scala/dependency/thrift/util_logging",
        "//scala/private/toolchain_deps:parser_combinators",
    ],
)

export_scrooge_deps(
    name = "compile_classpath",
    deps_id = "compile_classpath",
    visibility = ["//visibility:public"],
)

export_scrooge_deps(
    name = "aspect_compile_classpath",
    deps_id = "aspect_compile_classpath",
    visibility = ["//visibility:public"],
)

export_scrooge_deps(
    name = "scrooge_generator_classpath",
    deps_id = "scrooge_generator_classpath",
    visibility = ["//visibility:public"],
)

export_scrooge_deps(
    name = "compiler_classpath",
    deps_id = "compiler_classpath",
    visibility = ["//visibility:public"],
)
