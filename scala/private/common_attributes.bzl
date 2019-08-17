"""Shared attributes for rules"""

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
    "scalacopts": attr.string_list(),
    "javacopts": attr.string_list(),
    "jvm_flags": attr.string_list(),
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
}

common_attrs = {}

common_attrs.update(common_attrs_for_plugin_bootstrapping)

common_attrs.update({
    # using stricts scala deps is done by using command line flag called 'strict_java_deps'
    # switching mode to "on" means that ANY API change in a target's transitive dependencies will trigger a recompilation of that target,
    # on the other hand any internal change (i.e. on code that ijar omits) WON’T trigger recompilation by transitive dependencies
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
    "_unused_dependency_checker_plugin": attr.label(
        default = Label(
            "@io_bazel_rules_scala//third_party/unused_dependency_checker/src/main:unused_dependency_checker",
        ),
        allow_files = [".jar"],
        mandatory = False,
    ),
    "unused_dependency_checker_ignored_targets": attr.label_list(default = []),
    "_code_coverage_instrumentation_worker": attr.label(
        default = "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/coverage/instrumenter",
        allow_files = True,
        executable = True,
        cfg = "host",
    ),
})

implicit_deps = {
    "_singlejar": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@bazel_tools//tools/jdk:singlejar"),
        allow_files = True,
    ),
    "_zipper": attr.label(
        executable = True,
        cfg = "host",
        default = Label("@bazel_tools//tools/zip:zipper"),
        allow_files = True,
    ),
    "_java_toolchain": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_toolchain"),
    ),
    "_host_javabase": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
        cfg = "host",
    ),
    "_java_runtime": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
    ),
    "_scalac": attr.label(
        default = Label(
            "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac",
        ),
    ),
    "_exe": attr.label(
        executable = True,
        cfg = "host",
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
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            ),
        ],
        allow_files = False,
    ),
}

test_resolve_deps = {
    "_scala_toolchain": attr.label_list(
        default = [
            Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            ),
            Label(
                "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
            ),
        ],
        allow_files = False,
    ),
}
