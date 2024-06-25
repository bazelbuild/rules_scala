"""Shared attributes for rules"""

load("@bazel_features//:features.bzl", "bazel_features")
load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)
load(
    "@io_bazel_rules_scala//scala:plusone.bzl",
    _collect_plus_one_deps_aspect = "collect_plus_one_deps_aspect",
)

common_attrs_for_plugin_bootstrapping = {
    "srcs": attr.label_list(allow_files = [
        ".scala",
        ".srcjar",
        ".java",
    ]),
    "deps": attr.label_list(
        aspects = [
            _collect_plus_one_deps_aspect,
            _coverage_replacements_provider.aspect,
        ],
        providers = [[JavaInfo]],
    ),
    "plugins": attr.label_list(allow_files = [".jar"]),
    "runtime_deps": attr.label_list(providers = [[JavaInfo]]),
    "data": attr.label_list(allow_files = True),
    "resources": attr.label_list(allow_files = True),
    "resource_strip_prefix": attr.string(),
    "resource_jars": attr.label_list(allow_files = True),
    "java_compile_toolchain": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_toolchain"),
        providers = [java_common.JavaToolchainInfo],
    ),
    "scalacopts": attr.string_list(),
    "javacopts": attr.string_list(),
    "scalac_jvm_flags": attr.string_list(),
    "javac_jvm_flags": attr.string_list(),
    "expect_java_output": attr.bool(
        default = True,
        mandatory = False,
    ),
    "print_compile_time": attr.bool(
        default = False,
        mandatory = False,
    ),
    "neverlink": attr.bool(
        default = False,
        mandatory = False,
    ),
} | ({
    "add_exports": attr.string_list(),
    "add_opens": attr.string_list(),
} if bazel_features.java.java_info_constructor_module_flags else {})

common_attrs = {}

common_attrs.update(common_attrs_for_plugin_bootstrapping)

common_attrs.update({
    "_dependency_analyzer_plugin": attr.label(
        default = Label(
            "@io_bazel_rules_scala//third_party/dependency_analyzer/src/main:dependency_analyzer",
        ),
        allow_files = [".jar"],
        mandatory = False,
    ),
    "unused_dependency_checker_mode": attr.string(
        values = [
            "warn",
            "error",
            "off",
            "",
        ],
        mandatory = False,
    ),
    "unused_dependency_checker_ignored_targets": attr.label_list(default = []),
    "_code_coverage_instrumentation_worker": attr.label(
        default = "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/coverage/instrumenter",
        allow_files = True,
        executable = True,
        cfg = "exec",
    ),
})

implicit_deps = {
    "_java_runtime": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
    ),
    "_java_host_runtime": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_host_java_runtime"),
    ),
    "_scalac": attr.label(
        executable = True,
        cfg = "exec",
        default = Label("@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac"),
        allow_files = True,
    ),
    "_exe": attr.label(
        executable = True,
        cfg = "exec",
        default = Label("@io_bazel_rules_scala//src/java/io/bazel/rulesscala/exe:exe"),
    ),
}

launcher_template = {
    "_java_stub_template": attr.label(
        default = Label("@io_bazel_rules_scala//java_stub_template/file"),
    ),
}

# Single dep to allow IDEs to pickup all the implicit dependencies.
resolve_deps = {
    "_scala_toolchain": attr.label_list(
        default = [
            Label(
                "@io_bazel_rules_scala//scala/private/toolchain_deps:scala_library_classpath",
            ),
        ],
        allow_files = False,
    ),
}
