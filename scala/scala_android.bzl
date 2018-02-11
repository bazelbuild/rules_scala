load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

def scala_android_repositories():
    native.bind(name = "io_bazel_rules_scala/dependency/android_sdk", actual = "//tools/defaults:android_jar")

def scala_android_library(
        name,
        srcs = [],
        deps = [],
        resource_files = [],
        custom_package = None,
        manifest = None,
        proguard_specs = [],
        visibility = None,
        plugins = [],
        **kwargs):

    res_deps = []
    if len(resource_files) > 0:
        if manifest == None:
            fail("manifest is required when resource_files are present", "manifest")

        native.android_library(
            name = name + "_res",
            custom_package = custom_package,
            manifest = manifest,
            resource_files = resource_files,
            deps = deps,
            **kwargs
        )
        res_deps.append(name + "_res")

    scala_library(
        name = name + "_compile",
        srcs = srcs,
        plugins = plugins,
        deps = deps + ["//external:io_bazel_rules_scala/dependency/android_sdk"] + res_deps,
        **kwargs
    )

    native.java_import(
        name = name + "_scala",
        jars = [name + "_compile.jar"],
        deps = deps,
        visibility = visibility,
        exports = [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library"
        ],
    )

    native.android_library(
        name = name,
        exports = res_deps + [
            name + "_scala",
        ],
        proguard_specs = proguard_specs,
        visibility = visibility,
        custom_package = custom_package,
        manifest = manifest,
        **kwargs
    )
