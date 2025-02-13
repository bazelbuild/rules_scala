load(
    "@io_bazel_rules_scala//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
)
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)
load(
    "@io_bazel_rules_scala//scala:toolchains_repo.bzl",
    "scala_toolchains_repo",
)
load(
    "@io_bazel_rules_scala//twitter_scrooge/toolchain:toolchain.bzl",
    "twitter_scrooge",
)

def _import_external(id, artifact, sha256, deps = [], runtime_deps = []):
    _scala_maven_import_external(
        name = id,
        generated_rule_name = id,
        artifact = artifact,
        artifact_sha256 = sha256,
        licenses = ["notice"],
        server_urls = default_maven_server_urls(),
        deps = deps,
        runtime_deps = runtime_deps,
        testonly_ = False,
        fetch_sources = False,
    )

def scrooge_repositories(version = None):
    use_custom_toolchain_deps = False

    if version == "18.6.0":
        use_custom_toolchain_deps = True
        _import_external(
            id = "io_bazel_rules_scala_scrooge_core",
            artifact = "com.twitter:scrooge-core_2.11:18.6.0",
            sha256 = "00351f73b555d61cfe7320ef3b1367a9641e694cfb8dfa8a733cfcf49df872e8",
        )
        _import_external(
            id = "io_bazel_rules_scala_scrooge_generator",
            artifact = "com.twitter:scrooge-generator_2.11:18.6.0",
            sha256 = "0f0027e815e67985895a6f3caa137f02366ceeea4966498f34fb82cabb11dee6",
            runtime_deps = [
                "@io_bazel_rules_scala_guava",
                "@io_bazel_rules_scala_mustache",
                "@io_bazel_rules_scala_scopt",
            ],
        )
        _import_external(
            id = "io_bazel_rules_scala_util_core",
            artifact = "com.twitter:util-core_2.11:18.6.0",
            sha256 = "5336da4846dfc3db8ffe5ae076be1021828cfee35aa17bda9af461e203cf265c",
        )
        _import_external(
            id = "io_bazel_rules_scala_util_logging",
            artifact = "com.twitter:util-logging_2.11:18.6.0",
            sha256 = "73ddd61cedabd4dab82b30e6c52c1be6c692b063b8ba310d716ead9e3b4e9267",
        )

    elif version == "21.2.0":
        use_custom_toolchain_deps = True
        _import_external(
            id = "io_bazel_rules_scala_scrooge_core",
            artifact = "com.twitter:scrooge-core_2.11:21.2.0",
            sha256 = "d6cef1408e34b9989ea8bc4c567dac922db6248baffe2eeaa618a5b354edd2bb",
        )
        _import_external(
            id = "io_bazel_rules_scala_scrooge_generator",
            artifact = "com.twitter:scrooge-generator_2.11:21.2.0",
            sha256 = "87094f01df2c0670063ab6ebe156bb1a1bcdabeb95bc45552660b030287d6acb",
            runtime_deps = [
                "@io_bazel_rules_scala_guava",
                "@io_bazel_rules_scala_mustache",
                "@io_bazel_rules_scala_scopt",
            ],
        )
        _import_external(
            id = "io_bazel_rules_scala_util_core",
            artifact = "com.twitter:util-core_2.11:21.2.0",
            sha256 = "31c33d494ca5a877c1e5b5c1f569341e1d36e7b2c8b3fb0356fb2b6d4a3907ca",
        )
        _import_external(
            id = "io_bazel_rules_scala_util_logging",
            artifact = "com.twitter:util-logging_2.11:21.2.0",
            sha256 = "f3b62465963fbf0fe9860036e6255337996bb48a1a3f21a29503a2750d34f319",
        )

    toolchain_deps = {} if use_custom_toolchain_deps == False else {
        dep: "@io_bazel_rules_scala_%s" % dep
        for dep in [
            "scrooge_core",
            "scrooge_generator",
            "util_core",
            "util_logging",
        ]
    }

    twitter_scrooge(register_toolchains = False, **toolchain_deps)
    scala_toolchains_repo(
        name = "twitter_scrooge_test_toolchain",
        twitter_scrooge = True,
        twitter_scrooge_deps = toolchain_deps,
    )
