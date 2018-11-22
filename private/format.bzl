# Copyright 2018 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
""" Dependencies for linting/formatting.
"""

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
    "http_file",
)
load(
    "@bazel_tools//tools/build_defs/repo:java.bzl",
    "java_import_external",
)

def _com_github_google_yapf_repository_impl(rctx):
    rctx.download_and_extract(
        url = "https://github.com/google/yapf/archive/v0.21.0.tar.gz",
        stripPrefix = "yapf-0.21.0",
    )
    rctx.file("BUILD", """
alias(
    name="yapf",
    actual="//yapf:yapf",
    visibility = ["//visibility:public"],
)
""")
    rctx.file("yapf/BUILD", """
py_binary(
    name="yapf",
    srcs=glob(["**/*.py"]),
    main="__main__.py",
    visibility = ["//visibility:public"],
)""")

_com_github_google_yapf_repository = repository_rule(
    attrs = {},
    implementation = _com_github_google_yapf_repository_impl,
)

def format_repositories():
    _com_github_google_yapf_repository(name = "com_github_google_yapf")

    http_archive(
        name = "io_bazel",
        urls = [
            "https://github.com/bazelbuild/bazel/releases/download/0.11.1/bazel-0.11.1-dist.zip",
        ],
        sha256 = (
            "e8d762bcc01566fa50952c8028e95cfbe7545a39b8ceb3a0d0d6df33b25b333f"
        ),
    )

    java_import_external(
        name = "google_java_format",
        licenses = ["notice"],  # Apache 2.0
        jar_urls = [
            "https://github.com/google/google-java-format/releases/download/google-java-format-1.5/google-java-format-1.5-all-deps.jar",
        ],
        jar_sha256 = ("7b839bb7534a173f0ed0cd0e9a583181d20850fcec8cf6e3800e4420a1fad184"),
    )

    http_file(
        name = "io_bazel_buildifier_linux",
        urls = [
            "https://github.com/bazelbuild/buildtools/releases/download/0.11.1/buildifier",
        ],
        sha256 = (
            "d7d41def74991a34dfd2ac8a73804ff11c514c024a901f64ab07f45a3cf0cfef"
        ),
        executable = True,
    )

    http_file(
        name = "io_bazel_buildifier_darwin",
        urls = [
            "https://github.com/bazelbuild/buildtools/releases/download/0.11.1/buildifier.osx",
        ],
        sha256 = (
            "3cbd708ff77f36413cfaef89cd5790a1137da5dfc3d9b3b3ca3fac669fbc298b"
        ),
        executable = True,
    )
