load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def github_release(name, repository, release, sha256):
    (org, repo) = repository.split("/")
    http_archive(
        name = name,
        sha256 = sha256,
        urls = [
            "https://github.com/{repository}/releases/download/{release}/{repo}-{release}.tar.gz".format(repository = repository, repo = repo, release = release),
        ],
    )

def github_archive(name, repository, sha256, tag):
    http_archive(
        name = name,
        sha256 = sha256,
        strip_prefix = "{name}-{tag}".format(name = name, tag = tag),
        urls = [
            "https://github.com/{repository}/archive/{tag}.zip".format(repository = repository, tag = tag),
        ],
    )
