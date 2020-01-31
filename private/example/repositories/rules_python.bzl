"""load rules_python: needed by protobuf repo"""

load(":tools.bzl", _github_archive = "github_archive")

def load_rules_python():
    _github_archive(
        name = "rules_python",
        repository = "bazelbuild/rules_python",
        sha256 = "7d64815f4b22400bed0f1b9da663037e1578573446b7bc78f20f24b2b5459bb9",
        tag = "38f86fb55b698c51e8510c807489c9f4e047480e",
    )
