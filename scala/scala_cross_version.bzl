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
    _scala_maven_import_external = "scala_maven_import_external",
)

"""Helper functions for Scala cross-version support. Encapsulates the logic
of abstracting over Scala major version (2.11, 2.12, etc) for dependency
resolution."""

def default_scala_version():
    """return the scala version for use in maven coordinates"""
    return "2.12.11"

def default_scala_version_jar_shas():
    return {
        "scala_compiler": "e901937dbeeae1715b231a7cfcd547a10d5bbf0dfb9d52d2886eae18b4d62ab6",
        "scala_library": "dbfe77a3fc7a16c0c7cb6cb2b91fecec5438f2803112a744cb1b187926a138be",
        "scala_reflect": "5f9e156aeba45ef2c4d24b303405db259082739015190b3b334811843bd90d6a",
    }

def default_maven_server_urls():
    return [
        "https://repo.maven.apache.org/maven2",
        "https://maven-central.storage-download.googleapis.com/maven2",
        "https://mirror.bazel.build/repo1.maven.org/maven2",
        "https://jcenter.bintray.com",
    ]

def extract_major_version(scala_version):
    """Return major Scala version given a full version, e.g. "2.11.11" -> "2.11" """
    return scala_version[:scala_version.find(".", 2)]

def extract_major_version_underscore(scala_version):
    """Return major Scala version with underscore given a full version,
    e.g. "2.11.11" -> "2_11" """
    return extract_major_version(scala_version).replace(".", "_")

def default_scala_major_version():
    return extract_major_version(default_scala_version())

def scala_mvn_artifact(
        artifact,
        major_scala_version = default_scala_major_version()):
    """Add scala version to maven artifact"""
    gav = artifact.split(":")
    groupid = gav[0]
    artifactid = gav[1]
    version = gav[2]
    return "%s:%s_%s:%s" % (groupid, artifactid, major_scala_version, version)

def new_scala_default_repository(
        scala_version,
        scala_version_jar_shas,
        maven_servers,
        fetch_sources):
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scala_library",
        artifact = "org.scala-lang:scala-library:{}".format(scala_version),
        artifact_sha256 = scala_version_jar_shas["scala_library"],
        licenses = ["notice"],
        server_urls = maven_servers,
        fetch_sources = fetch_sources,
    )
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scala_compiler",
        artifact = "org.scala-lang:scala-compiler:{}".format(scala_version),
        artifact_sha256 = scala_version_jar_shas["scala_compiler"],
        licenses = ["notice"],
        server_urls = maven_servers,
        fetch_sources = fetch_sources,
    )
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scala_reflect",
        artifact = "org.scala-lang:scala-reflect:{}".format(scala_version),
        artifact_sha256 = scala_version_jar_shas["scala_reflect"],
        licenses = ["notice"],
        server_urls = maven_servers,
        fetch_sources = fetch_sources,
    )
