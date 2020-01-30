"""load skylib"""

load(":tools.bzl", _github_release = "github_release")

def load_bazel_skylib():
    _github_release(
        name = "bazel_skylib",
        sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
        repository = "bazelbuild/bazel-skylib",
        release = "1.0.2",
    )
