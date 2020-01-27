load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":tools.bzl", _maven_install = "maven_install")
load("@io_bazel_rules_scala_configuration//:configuration.bzl", _configuration = "configuration", _versions = "versions")
load("@rules_jvm_external//:defs.bzl", _artifact = "artifact")

def _github_archive(name, repository, sha256, tag):
    (org, repo) = repository.split("/")
    without_v = tag[1:] if tag.startswith("v") else tag
    http_archive(
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
        sha256 = "",
        repository = "protocolbuffers/protobuf",
        tag = "v3.11.2",
    )
    if _configuration["compatability_labels"]:
        native.bind(
            name = "io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
            actual = "@com_google_protobuf//:protobuf_java",
        )

def _create_maven_installed_repos():
    for version in _versions():
        repository_name = "io_bazel_rules_scala_" + version["mvn"]
        artifacts = {
            "org.scala-lang:scala-compiler:" + version["complete"]: "io_bazel_rules_scala/dependency/scala/scala_compiler",
            "org.scala-lang:scala-library:" + version["complete"]:  "io_bazel_rules_scala/dependency/scala/scala_library",
            "org.scala-lang:scala-reflect:" + version["complete"]:  "io_bazel_rules_scala/dependency/scala/scala_reflect",
        }

        _maven_install(
            name = repository_name,
            artifacts = _maven_install_artifacts(artifacts),
            repositories = version["repositories"],
        )

        if version["default"] and version["compatability_labels"]: _bind_default_labels(repository_name, artifacts)

    java_artifacts = {
        "commons-io:commons-io:2.6": "io_bazel_rules_scala/dependency/scalac_rules_commons_io",
    }

    _maven_install(
        name = "io_bazel_rules_scala_scalac",
        artifacts = _maven_install_artifacts(java_artifacts),
        repositories = _configuration["repositories"],
    )
    if _configuration["compatability_labels"]:  _bind_default_labels("io_bazel_rules_scala_scalac", java_artifacts)
