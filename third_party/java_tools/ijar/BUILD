load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")
load("@bazel_tools//tools/build_rules:test_rules.bzl", "file_test")

package(
    default_visibility = [
        "//visibility:public",
    ],
)

licenses(["notice"])  # Apache 2.0

cc_library(
    name = "zip",
    srcs = [
        "mapped_file_unix.cc",
        "zip.cc",
    ],
    hdrs = [
        "common.h",
        "mapped_file.h",
        "zip.h",
    ],
    deps = [
        ":platform_utils",
        ":zlib_client",
    ],
)

cc_library(
    name = "zlib_client",
    srcs = ["zlib_client.cc"],
    hdrs = [
        "common.h",
        "zlib_client.h",
    ],
    deps = ["//third_party/java_tools/zlib"],
)

cc_library(
    name = "platform_utils",
    srcs = ["platform_utils.cc"],
    hdrs = [
        "common.h",
        "platform_utils.h",
    ],
    deps = [
        "//third_party/java_tools/src/main/cpp/util:errors",
        "//third_party/java_tools/src/main/cpp/util:filesystem",
        "//third_party/java_tools/src/main/cpp/util:logging",
    ],
)
#
#cc_binary(
#    name = "zipper",
#    srcs = ["zip_main.cc"],
#    visibility = ["//visibility:public"],
#    deps = [":zip"],
#)

cc_binary(
    name = "ijar",
    srcs = [
        "classfile.cc",
        "ijar.cc",
    ],
    deps = [":zip"],
)

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
)

#filegroup(
#    name = "embedded_zipper_sources",
#    srcs = [
#        "zip.cc",
#        "zip.h",
#        "zip_main.cc",
#        "common.h",
#        "mapped_file.h",
#        "platform_utils.cc",
#        "platform_utils.h",
#        "zlib_client.cc",
#        "zlib_client.h",
#        "BUILD",
#    ] + select({
#        "//src:windows": [
#            "mapped_file_windows.cc",
#        ],
#        "//conditions:default": [
#            "mapped_file_unix.cc",
#        ],
#    }),
#    visibility = ["//visibility:public"],
#)

#filegroup(
#    name = "transitive_sources",
#    srcs = [":srcs"] + ["//src/main/cpp/util:embedded_java_tools"],
#)

#genrule(
#    name = "ijar_transitive_srcs_zip",
#    srcs = [
#        ":ijar_srcs_zip",
#        "//src:zlib_zip",
#        "//src/main/cpp/util:cpp_util_with_deps_zip",
#    ],
#    outs = ["ijar_srcs_with_deps.zip"],
#    cmd = "$(location //src:merge_zip_files) java_tools $@ $(SRCS)",
#    tools = ["//src:merge_zip_files"],
#)

#genrule(
#    name = "ijar_deploy_zip",
#    srcs = [
#        ":ijar",
#        ":zipper",
#    ],
#    outs = ["ijar_deploy.zip"],
#    cmd = "$(location //src:zip_files) java_tools/ijar $@ $(SRCS)",
#    tools = ["//src:zip_files"],
#)

#genrule(
#    name = "ijar_srcs_zip",
#    srcs = glob(
#        ["**"],
#        exclude = ["BUILD"],
#    ),
#    outs = ["ijar_srcs.zip"],
#    cmd = "$(location //src:zip_files) ijar $@ $(SRCS)",
#    tools = ["//src:zip_files"],
#)

genrule(
    name = "test-input-manifest",
    outs = ["input.mf"],
    cmd = """cat <<EOF >> $@
Manifest-Version: 1.0
Created-By: bazel
Class-Path: class-path-entry
EOF""",
)

genrule(
    name = "test-input-jar",
    srcs = [":test-input-manifest"],
    outs = ["input.jar"],
    cmd = "$(JAVABASE)/bin/jar -cfm $@ $<",
    toolchains = ["@bazel_tools//tools/jdk:current_java_runtime"],
)

genrule(
    name = "test-modified-jar",
    srcs = [":test-input-jar"],
    outs = ["modified.jar"],
    cmd = "$(location :ijar) --nostrip_jar --target_label label $< $@",
    tools = [":ijar"],
)

genrule(
    name = "test-modified-manifest",
    srcs = [":test-modified-jar"],
    outs = ["modified.mf"],
    cmd = "$(JAVABASE)/bin/jar -xf $< META-INF/MANIFEST.MF && mv META-INF/MANIFEST.MF $@",
    toolchains = ["@bazel_tools//tools/jdk:current_java_runtime"],
)

file_test(
    name = "test-modified-manifest-content",
    content = "\r\n".join([
        "Manifest-Version: 1.0",
        "Created-By: bazel",
        "Target-Label: label",
        "",
        "",
    ]),
    file = ":test-modified-manifest",
)
