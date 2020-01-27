"""load rules_jvm_external"""

load(":tools.bzl", _github_archive = "github_archive")

def load_rules_jvm_external():
    _github_archive(
        name = "rules_jvm_external",
        repository = "bazelbuild/rules_jvm_external",
        sha256 = "62133c125bf4109dfd9d2af64830208356ce4ef8b165a6ef15bbff7460b35c3a",
        tag = "3.0",
    )
