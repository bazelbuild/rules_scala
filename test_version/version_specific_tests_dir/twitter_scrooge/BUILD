dependencies_to_test = [
    "scrooge_core",
    "scrooge_generator",
    "util_core",
    "util_logging",
]

deps_with_external_binds = [
    (
        dep_name,
        "//external:io_bazel_rules_scala/dependency/thrift/{}".format(dep_name),
    )
    for dep_name in dependencies_to_test
]

# Test that the filename of a dependency contains the version of scrooge we're testing.
# This test passes two args to the shell script:
# . The rootpath of the //external` binding to the scrooge dependency. This returns the path to the actual jar.
# . A string containing the version of the dependency we want to test. This is passed via `--test_args` from `test_version.sh`,
# .   and added to the `args` attribute of this target.
[
    sh_test(
        name = "test_{}_version".format(
            dep_name,
        ),
        srcs = ["dependency_version_in_filename.sh"],
        args = [
            "$(rootpath {})".format(path_to_external_bind),
        ],
        data = [path_to_external_bind],
    )
    for (dep_name, path_to_external_bind) in deps_with_external_binds
]
