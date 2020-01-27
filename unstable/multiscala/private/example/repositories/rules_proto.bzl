"""load rules_proto: needed by protobuf repo"""

load(":tools.bzl", _github_archive = "github_archive")

def load_rules_proto():
    _github_archive(
        name = "rules_proto",
        repository = "bazelbuild/rules_proto",
        sha256 = "62847ac7740865d73a2c8199be292bba913d62e79084442f3e829c3058a25e64",
        tag = "d7666ec475c1f8d4a6803cbc0a0b6b4374360868",
    )
