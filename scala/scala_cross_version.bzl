# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Helper functions for Scala cross-version support. Encapsulates the logic
of abstracting over Scala major version (2.11, 2.12, etc) for dependency
resolution."""

def scala_version():
  """return the scala version for use in maven coordinates"""
  return "2.11"

def scala_mvn_artifact(artifact):
  gav = artifact.split(":")
  groupid = gav[0]
  artifactid = gav[1]
  version = gav[2]
  return "%s:%s_%s:%s" % (groupid, artifactid, scala_version(), version)

def _generate_scala_imports(version):
  return """
# scala.BUILD
load("@io_bazel_rules_scala//scala:providers.bzl",
     _declare_scalac_provider = "declare_scalac_provider",
)

java_import(
    name = "scala-library",
    jars = ["lib/scala-library.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-compiler",
    jars = ["lib/scala-compiler.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-reflect",
    jars = ["lib/scala-reflect.jar"],
    visibility = ["//visibility:public"],
)
  """.format(version = version)

def _generate_scalac_build_file_impl(repository_ctx):
  scalac_worker_srcs = [
      "CompileOptions.java",
      "ScalaCInvoker.java",
      "ScalacProcessor.java",
      "Resource.java",
  ]

  for src in scalac_worker_srcs:
    path = Label("@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac:{}".format(src))
    repository_ctx.symlink(path, "scalac_worker_srcs_symlinked/{}".format(src))

  contents = """
load("@io_bazel_rules_scala//scala:providers.bzl",
     _declare_scalac_provider = "declare_scalac_provider",
)

java_binary(
    name = "scalac_worker",
    srcs = glob(["scalac_worker_srcs_symlinked/*.java"]),
    main_class = "io.bazel.rulesscala.scalac.ScalaCInvoker",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala//src/java/com/google/devtools/build/lib:worker",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
        '//external:io_bazel_rules_scala/dependency/commons_io/commons_io',
        '@{archive}//:scala-compiler',
        '@{archive}//:scala-library',
        '@{archive}//:scala-reflect',
    ],
)

_declare_scalac_provider(
    name = "{name}",
    major_version = "{major_version}",
    scalac = ":scalac_worker",
    scalalib = "@{archive}//:scala-library",
    scalareflect = "@{archive}//:scala-reflect",
    scalaxml = "@scala_xml_{version_with_underscore}//jar",
    scalacompiler = "@{archive}//:scala-compiler",
    scalatest = ["@scalatest_{version_with_underscore}//jar", "@scalactic_{version_with_underscore}//jar"],
    scalatest_runner = "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scala_test:runner.jar",
    visibility = ["//visibility:public"],
)
    """.format(
      archive = repository_ctx.attr.archive,
      name = repository_ctx.attr.name,
      major_version = repository_ctx.attr.major_version,
      version_with_underscore = repository_ctx.attr.major_version.replace(".", "_"))

  repository_ctx.file("BUILD", contents, False)

_generate_scalac_build_file = repository_rule(
    implementation = _generate_scalac_build_file_impl,
    attrs = {"archive": attr.string(), "major_version": attr.string()})

def new_scala_repository(name, version):
  major_version = version[:version.find(".", 2)]
  archive = "{name}_imports".format(name = name)
  native.new_http_archive(
      name = archive,
      strip_prefix = "scala-{version}".format(version = version),
      url =
      "https://downloads.lightbend.com/scala/{version}/scala-{version}.tgz".
      format(version = version),
      build_file_content = _generate_scala_imports(major_version),
  )

  _generate_scalac_build_file(
      name = name, archive = archive, major_version = major_version, visibility = ["//visibility:public"])
