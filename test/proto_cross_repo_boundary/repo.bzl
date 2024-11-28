"""Macro for creating the @proto_cross_repo_boundary repo for testing"""

# Once we switch to Bazel 7, uncomment this `load` statement remove the
# `native.` prefix from `new_local_repository`.
#load("@bazel_tools//tools/build_defs/repo:local.bzl", "new_local_repository")

def proto_cross_repo_boundary_repository(
        name = "proto_cross_repo_boundary"):
    """Creates the @proto_cross_repo_boundary repo for rules_scala testing."""
    native.new_local_repository(
        name = name,
        path = "test/proto_cross_repo_boundary/repo",
        build_file = "//test/proto_cross_repo_boundary:repo/BUILD.repo",
    )
