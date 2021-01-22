# Description:
#   C++ utility source for Bazel
package_group(
    name = "ijar",
    packages = [
        "//third_party/ijar/...",
    ],
)

package(default_visibility = ["//visibility:public"])

load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "util",
    hdrs = [
        "errors.h",
        "file.h",
        "file_platform.h",
        "md5.h",
        "numbers.h",
        "path.h",
        "path_platform.h",
        "port.h",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":blaze_exit_code",
        ":errors",
        ":filesystem",
        ":md5",
        ":numbers",
        ":port",
        ":strings",
    ],
)

cc_library(
    name = "filesystem",
    srcs = [
        "file.cc",
        "file_posix.cc",
        "path.cc",
        "path_posix.cc",
    ],
    hdrs = [
        "file.h",
        "file_platform.h",
        "path.h",
        "path_platform.h",
    ],
    deps = [
        ":blaze_exit_code",
        ":errors",
        ":logging",
        ":strings",
    ],
)

cc_library(
    name = "errors",
    srcs = ["errors_posix.cc"],
    hdrs = ["errors.h"],
    deps = [
        ":logging",
        ":port",
        ":strings",
    ],
)

cc_library(
    name = "port",
    srcs = ["port.cc"],
    hdrs = ["port.h"],
)

cc_library(
    name = "numbers",
    srcs = ["numbers.cc"],
    hdrs = ["numbers.h"],
    deps = [":strings"],
)

cc_library(
    name = "logging",
    srcs = ["logging.cc"],
    hdrs = ["logging.h"],
    deps = [
        ":blaze_exit_code",
        ":strings",
    ],
)

cc_library(
    name = "bazel_log_handler",
    srcs = ["bazel_log_handler.cc"],
    hdrs = ["bazel_log_handler.h"],
    deps = [
        ":blaze_exit_code",
        ":filesystem",
        ":logging",
    ],
)

cc_library(
    name = "md5",
    srcs = ["md5.cc"],
    hdrs = ["md5.h"],
)

cc_library(
    name = "strings",
    srcs = ["strings.cc"],
    hdrs = ["strings.h"],
    # Automatically propagate the symbol definition to rules depending on this.
    defines = [
        "BLAZE_OPENSOURCE",
    ],
    visibility = ["//visibility:public"],
    deps = [":blaze_exit_code"],
)

cc_library(
    name = "blaze_exit_code",
    hdrs = ["exit_code.h"],
)

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
)

filegroup(
    name = "embedded_tools",
    srcs = glob(["*.cc"]) + glob(["*.h"]) + ["BUILD"],
)

filegroup(
    name = "embedded_java_tools",
    srcs = glob(["*.cc"]) + glob(["*.h"]),
)
