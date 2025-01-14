load("//junit:junit.bzl", "junit_artifact_ids")
load("//scalatest:scalatest.bzl", "scalatest_artifact_ids")
load("//specs2:specs2.bzl", "specs2_artifact_ids")
load("//specs2:specs2_junit.bzl", "specs2_junit_artifact_ids")

def _repoize(ids):
    return ["@" + id for id in ids]

JUNIT_DEPS = _repoize(junit_artifact_ids())

SCALATEST_DEPS = _repoize(scalatest_artifact_ids())

SPECS2_DEPS = _repoize(specs2_artifact_ids())

SPECS2_JUNIT_DEPS = _repoize(specs2_junit_artifact_ids())
