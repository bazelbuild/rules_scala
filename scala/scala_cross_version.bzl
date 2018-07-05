# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external")
"""Helper functions for Scala cross-version support. Encapsulates the logic
of abstracting over Scala major version (2.11, 2.12, etc) for dependency
resolution."""

def default_scala_version():
  """return the scala version for use in maven coordinates"""
  return "2.11.12"

def default_scala_version_jar_shas():
  return {
      "scala_compiler": "3e892546b72ab547cb77de4d840bcfd05c853e73390fed7370a8f19acb0735a0",
      "scala_library": "0b3d6fd42958ee98715ba2ec5fe221f4ca1e694d7c981b0ae0cd68e97baf6dce",
      "scala_reflect": "6ba385b450a6311a15c918cf8688b9af9327c6104f0ecbd35933cfcd3095fe04",
  }

def scala_mvn_artifact(artifact, major_scala_version):
  """Add scala version to maven artifact"""
  gav = artifact.split(":")
  groupid = gav[0]
  artifactid = gav[1]
  version = gav[2]
  return "%s:%s_%s:%s" % (groupid, artifactid, major_scala_version, version)

def extract_major_version(scala_version):
  """Return major Scala version given a full version, e.g. "2.11.11" -> "2.11" """
  return scala_version[:scala_version.find(".", 2)]

def extract_major_version_underscore(scala_version):
  """Return major Scala version with underscore given a full version,
  e.g. "2.11.11" -> "2_11" """
  return extract_major_version(scala_version).replace(".", "_")

def default_scala_major_version():
  return extract_major_version(default_scala_version())

def _generate_scalac_build_file_impl(repository_ctx):
  scalac_worker_srcs = [
      "CompileOptions.java",
      "ScalaCInvoker.java",
      "ScalacProcessor.java",
      "Resource.java",
  ]

  for src in scalac_worker_srcs:
    path = Label(
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac:{}".format(
            src))
    repository_ctx.symlink(path, "scalac_worker_srcs_symlinked/{}".format(src))

  contents = """
load("@io_bazel_rules_scala//scala:providers.bzl",
     _declare_scalac_provider = "declare_scalac_provider",
)

java_binary(
    name = "scalac_worker",
    srcs = glob(["scalac_worker_srcs_symlinked/*.java"]),
    javacopts = [
      "-source 1.8",
      "-target 1.8"
    ],
    main_class = "io.bazel.rulesscala.scalac.ScalaCInvoker",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala//src/java/com/google/devtools/build/lib:worker",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
        "@scalac_rules_commons_io//jar",
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
        "@io_bazel_rules_scala_scala_compiler",
    ],
)

_declare_scalac_provider(
    name = "{name}",
    scalac = "@{name}//:scalac_worker",
    default_classpath = ["@io_bazel_rules_scala_scala_library"],
    default_repl_classpath = [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
        "@io_bazel_rules_scala_scala_compiler"
    ],
    default_macro_classpath = [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect"
    ],
    visibility = ["//visibility:public"],
)
    """.format(
      name = repository_ctx.attr.name,
      version_underscore = repository_ctx.attr.version_underscore)

  repository_ctx.file("BUILD", contents, False)

_generate_scalac_build_file = repository_rule(
    implementation = _generate_scalac_build_file_impl,
    attrs = {
        "version_underscore": attr.string(),
    })

def new_scala_repository(name, scala_version, scala_version_jar_shas,
                         maven_servers):
  scala_version_underscore = scala_version.replace(".", "_")

  _scala_maven_import_external(
      name = "io_bazel_rules_scala_scala_library",
      artifact = "org.scala-lang:scala-library:{}".format(scala_version),
      jar_sha256 = scala_version_jar_shas["scala_library"],
      licenses = ["notice"],
      server_urls = maven_servers,
  )
  _scala_maven_import_external(
      name = "io_bazel_rules_scala_scala_compiler",
      artifact = "org.scala-lang:scala-compiler:{}".format(scala_version),
      jar_sha256 = scala_version_jar_shas["scala_compiler"],
      licenses = ["notice"],
      server_urls = maven_servers,
  )
  _scala_maven_import_external(
      name = "io_bazel_rules_scala_scala_reflect",
      artifact = "org.scala-lang:scala-reflect:{}".format(scala_version),
      jar_sha256 = scala_version_jar_shas["scala_reflect"],
      licenses = ["notice"],
      server_urls = maven_servers,
  )

  _generate_scalac_build_file(
      name = name,
      version_underscore = scala_version_underscore,
      visibility = ["//visibility:public"])
