load("//specs2:specs2.bzl", "specs2_dependencies")

def specs2_junit_artifact_ids():
    return [
        "io_bazel_rules_scala_org_specs2_specs2_junit",
    ]

def specs2_junit_dependencies():
    return specs2_dependencies() + [
        Label("//testing/toolchain:specs2_junit_classpath"),
    ]
