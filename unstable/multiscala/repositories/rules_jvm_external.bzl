"""load rules_jvm_external"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _github_archive(name, repository, sha256, tag):
    (org, repo) = repository.split("/")
    without_v = tag[1:] if tag.startswith("v") else tag
    http_archive(
        name = name,
        sha256 = sha256,
        strip_prefix = "{repo}-{without_v}".format(repo = repo, without_v = without_v),
        urls = [
            "https://github.com/{repository}/archive/{tag}.zip".format(repository = repository, tag = tag),
        ],
    )

def load_rules_jvm_external():
    _github_archive(
        name = "rules_jvm_external",
        repository = "bazelbuild/rules_jvm_external",
        sha256 = "62133c125bf4109dfd9d2af64830208356ce4ef8b165a6ef15bbff7460b35c3a",
        tag = "3.0",
    )
