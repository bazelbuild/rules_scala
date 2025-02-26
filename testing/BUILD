load("//scala:scala_cross_version.bzl", "version_suffix")
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")

# Aliases for backward compatibility:
[
    alias(
        name = framework + "_toolchain",
        actual = (
            "@rules_scala_toolchains//testing:testing_toolchain" +
            version_suffix(SCALA_VERSION)
        ),
    )
    for framework in [
        "testing",
        "scalatest",
        "specs2_junit",
        "junit",
    ]
]
