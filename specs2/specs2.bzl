def specs2_artifact_ids():
    return [
        "io_bazel_rules_scala_org_specs2_specs2_common",
        "io_bazel_rules_scala_org_specs2_specs2_core",
        "io_bazel_rules_scala_org_specs2_specs2_fp",
        "io_bazel_rules_scala_org_specs2_specs2_matcher",
    ]

def specs2_dependencies():
    return [Label("//specs2:specs2")]
