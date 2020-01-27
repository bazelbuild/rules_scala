load(":tools.bzl", _maven_install = "maven_install")
load("@io_bazel_rules_scala_configuration//:configuration.bzl", _versions = "versions")
load("@rules_jvm_external//:defs.bzl", _artifact = "artifact")

def create_repositories():
    for version in _versions():
        repository_name = "io_bazel_rules_scala_" + version["mvn"]
        _maven_install(
            name = repository_name,
            artifacts = [
                "org.scala-lang:scala-compiler:" + version["complete"],
                "org.scala-lang:scala-library:" + version["complete"],
                "org.scala-lang:scala-reflect:" + version["complete"],
            ],
            repositories = version["repositories"],
        )
        if version["compatability_labels"]:
            native.bind(
                name = "io_bazel_rules_scala/dependency/scala/scala_library",
                actual = _artifact("org.scala-lang:scala-library", repository_name = repository_name)
            )
            native.bind(
                name = "io_bazel_rules_scala/dependency/scala/scala_compiler",
                actual = _artifact("org.scala-lang:scala-compiler", repository_name = repository_name)
            )
            native.bind(
                name = "io_bazel_rules_scala/dependency/scala/scala_reflect",
                actual = _artifact("org.scala-lang:scala-reflect", repository_name = repository_name)
            )

        if version["default"] and version["compatability_labels"]:
            pass
    _maven_install(
        name = "io_bazel_rules_scala_scalac",
        artifacts = [
            "commons-io:commons-io:2.6"
        ],
        repositories = version["repositories"],
    )
    if version["compatability_labels"]:
        native.bind(
            name = "io_bazel_rules_scala/dependency/scalac_rules_commons_io",
            actual = _artifact("commons-io:commons-io", repository_name = "io_bazel_rules_scala_scalac")
        )
