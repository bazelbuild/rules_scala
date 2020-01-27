def load_rules_scala():
    native.local_repository(
        name = "io_bazel_rules_scala",
        path = "../../../..",
    )
