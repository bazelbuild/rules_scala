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

"""Helper functions for Scala cross-version support. Encapsulates the logic
of abstracting over Scala major version (2.11, 2.12, etc) for dependency
resolution."""

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

def extract_minor_version(scala_version):
    return scala_version.split(".")[2]

def extract_major_version_underscore(scala_version):
    """Return major Scala version with underscore given a full version,
    e.g. "2.11.11" -> "2_11" """
    return extract_major_version(scala_version).replace(".", "_")

def scala_mvn_artifact(
        artifact,
        major_scala_version):
    """Add scala version to maven artifact"""
    gav = artifact.split(":")
    groupid = gav[0]
    artifactid = gav[1]
    version = gav[2]
    return "%s:%s_%s:%s" % (groupid, artifactid, major_scala_version, version)
