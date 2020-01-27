load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load(":tools.bzl", _maven_install = "maven_install")
load("@io_bazel_rules_scala_configuration//:configuration.bzl", _configuration = "configuration", _versions = "versions")
load("@rules_jvm_external//:defs.bzl", _artifact = "artifact")

def _github_archive(name, repository, sha256, tag):
    (org, repo) = repository.split("/")
    without_v = tag[1:] if tag.startswith("v") else tag
    _http_archive(
        name = name,
        sha256 = sha256,
        strip_prefix = "{repo}-{without_v}".format(repo = repo, without_v = without_v),
        urls = [
            "https://github.com/{repository}/archive/{tag}.zip".format(repository = repository, tag = tag),
        ],
    )

def _maven_install_artifacts(artifacts):
    return artifacts.keys()

def _bind_default_labels(repository_name, artifacts):
    for artifact in artifacts.items():
        (mvn, label) = artifact
        without_version = ":".join(mvn.split(":")[0:2])
        native.bind(
            name = label,
            actual = _artifact(without_version, repository_name = repository_name)
        )

def create_repositories():
    _create_protobuf()
    _create_maven_installed_repos()

def _create_protobuf():
    _github_archive(
        name = "com_google_protobuf",
        sha256 = "e4f8bedb19a93d0dccc359a126f51158282e0b24d92e0cad9c76a9699698268d",
        repository = "protocolbuffers/protobuf",
        tag = "v3.11.2",
    )

    # N.B.: could use protobuf/protobuf_deps.bzl

    _http_archive(
        name = "zlib",
        build_file = "@com_google_protobuf//:third_party/zlib.BUILD",
        sha256 = "629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff",
        strip_prefix = "zlib-1.2.11",
        urls = ["https://github.com/madler/zlib/archive/v1.2.11.tar.gz"],
    )

    if _configuration["compatability_labels"]:
        native.bind(
            name = "io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
            actual = "@com_google_protobuf//:protobuf_java",
        )

def _scala_artifact(version, scala_coordinate):
    components = scala_coordinate.split(":")
    if len(components) == 2:
        components.append("{" + components[1] + "}")
    (org, artifact, artifact_version) = components
    java_coordinate = ":".join([org, artifact + "_" + version["scala"], artifact_version])
    return java_coordinate.format(**version)

def _create_maven_installed_repos():
    for version in _versions():
        repository_name = "io_bazel_rules_scala_" + version["mvn"]

        artifacts = {
            "org.scala-lang:scala-compiler:" + version["complete"]: "io_bazel_rules_scala/dependency/scala/scala_compiler",
            "org.scala-lang:scala-library:" + version["complete"]:  "io_bazel_rules_scala/dependency/scala/scala_library",
            "org.scala-lang:scala-reflect:" + version["complete"]:  "io_bazel_rules_scala/dependency/scala/scala_reflect",
            _scala_artifact(version, "org.scala-lang.modules:scala-xml"): "io_bazel_rules_scala/dependency/scala/scala_xml",
            _scala_artifact(version, "org.scalatest:scalatest"): "io_bazel_rules_scala/dependency/scala/scalatest/scalatest",
            _scala_artifact(version, "org.scalactic:scalactic"): "io_bazel_rules_scala/dependency/scala/scalactic/scalactic",
        }

        _maven_install(
            name = repository_name,
            artifacts = _maven_install_artifacts(artifacts),
            repositories = version["repositories"],
        )

        if version["default"] and version["compatability_labels"]: _bind_default_labels(repository_name, artifacts)

        if version["default"] and version["compatability_labels"]:
            native.bind(
                name = "io_bazel_rules_scala/dependency/scalatest/scalatest",
                actual = "@io_bazel_rules_scala//scala/scalatest:scalatest",
            )

    java_artifacts = {
        "commons-io:commons-io:2.6": "io_bazel_rules_scala/dependency/scalac_rules_commons_io",
        "com.google.guava:guava:21.0": "io_bazel_rules_scala/dependency/scala/guava",
    }

    _maven_install(
        name = "io_bazel_rules_scala_scalac",
        artifacts = _maven_install_artifacts(java_artifacts),
        repositories = _configuration["repositories"],
    )
    if _configuration["compatability_labels"]:  _bind_default_labels("io_bazel_rules_scala_scalac", java_artifacts)
