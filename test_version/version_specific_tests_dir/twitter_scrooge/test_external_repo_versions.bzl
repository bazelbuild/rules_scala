def external_dependency_version_tests():
    dependencies_to_test = [
        "scrooge_core",
        "scrooge_generator",
        "util_core",
        "util_logging",
    ]

    for dep in dependencies_to_test:
        path_to_external_bind = "//external:io_bazel_rules_scala/dependency/thrift/{}".format(dep)
        native.sh_test(
            name = "test_{}_version".format(
                dep,
            ),
            srcs = ["dependency_version_in_filename.sh"],
            args = [
                "$(rootpath {})".format(path_to_external_bind),
            ],
            data = [path_to_external_bind],
        )
