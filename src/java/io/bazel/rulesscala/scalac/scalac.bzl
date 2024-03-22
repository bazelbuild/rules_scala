load("@rules_java//java:defs.bzl", "java_binary", "java_library")
load("@io_bazel_rules_scala_config//:config.bzl", "ENABLE_COMPILER_DEPENDENCY_TRACKING", "SCALA_VERSIONS")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "extract_major_version", "extract_minor_version", "version_suffix")

_SCALAC_DEPS = [
    "//scala/private/toolchain_deps:scala_compile_classpath",
    "//src/java/io/bazel/rulesscala/io_utils",
    "@bazel_tools//src/main/protobuf:worker_protocol_java_proto",
    "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
    "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
    "@io_bazel_rules_scala//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    "//src/java/io/bazel/rulesscala/scalac/compileoptions",
]

def setup_scalac():
    for scala_version in SCALA_VERSIONS:
        _scalac(scala_version)

def _scalac(scala_version):
    suffix = version_suffix(scala_version)

    java_library(
        name = "scalac_reporter" + suffix,
        srcs = _reporter_srcs(extract_major_version(scala_version), extract_minor_version(scala_version)),
        deps = [
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac/reporter:scala_deps_java_proto",
            "//scala/private/toolchain_deps:scala_compile_classpath",
            "//src/java/io/bazel/rulesscala/scalac/compileoptions",
            "@io_bazel_rules_scala//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
        ],
        visibility = ["//visibility:public"],
    )
    java_binary(
        name = "scalac" + suffix,
        srcs = _scalac_srcs(scala_version),
        javacopts = [
            "-source 1.8",
            "-target 1.8",
        ],
        main_class = "io.bazel.rulesscala.scalac.ScalacWorker",
        visibility = ["//visibility:public"],
        deps = _dep_reporting_deps(scala_version) + _SCALAC_DEPS + [":scalac_reporter" + suffix],
    )
    java_binary(
        name = "scalac_bootstrap" + suffix,
        srcs = _scalac_srcs(scala_version),
        javacopts = [
            "-source 1.8",
            "-target 1.8",
        ],
        main_class = "io.bazel.rulesscala.scalac.ScalacWorker",
        visibility = ["//visibility:public"],
        deps = _SCALAC_DEPS + [":scalac_reporter" + suffix],
    )

def _reporter_srcs(scala_major_version, scala_minor_version):
    if (scala_major_version == "2.11") or (scala_major_version == "2.12" and int(scala_minor_version) < 13):
        return [
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter:before_2_12_13",
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac/reporter:before_2_12_13",
        ]
    elif (scala_major_version == "2.12" and int(scala_minor_version) >= 13) or (scala_major_version == "2.13" and int(scala_minor_version) < 12):
        return [
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter:after_2_12_13_and_before_2_13_12",
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac/reporter:after_2_12_13_and_before_2_13_12",
        ]
    elif (scala_major_version == "2.13" and int(scala_minor_version) >= 12):
        return [
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter:after_2_13_12",
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac/reporter:after_2_13_12",
        ]
    else:
        return [
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac/reporter:scala_3",
        ]

def _scalac_srcs(scala_version):
    if scala_version.startswith("2"):
        return ["@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac:scalac_2"]
    else:
        return ["@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac:scalac_3"]

def _source_jar(ctx):
    java_common.pack_sources(
        ctx.actions,
        sources = ctx.files.srcs,
        output_source_jar = ctx.outputs.outs,
        java_toolchain = ctx.toolchains["@bazel_tools//tools/jdk:toolchain_type"].java,
    )

def _dep_reporting_deps(scala_version):
    if (ENABLE_COMPILER_DEPENDENCY_TRACKING and scala_version.startswith("2")):
        return ["//third_party/dependency_analyzer/src/main/io/bazel/rulesscala/dependencyanalyzer/compiler:dep_reporting_compiler" + version_suffix(scala_version)]
    else:
        return []

source_jar = rule(
    implementation = _source_jar,
    attrs = {
        "srcs": attr.label_list(mandatory = True, allow_empty = False, allow_files = True),
        "outs": attr.output(mandatory = True),
    },
    toolchains = ["@bazel_tools//tools/jdk:toolchain_type"],
)
