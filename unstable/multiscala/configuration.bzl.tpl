# -*- mode: python -*-

load("@io_bazel_rules_scala//unstable/multiscala:tools.bzl", _maven_install = "maven_install")
load("@rules_jvm_external//:defs.bzl", _artifact = "artifact")

def _from_json():
    # starlark vs json ...

    true = True
    false = False
    null = None

    return %{STARLARK_STRING}

configuration = _from_json()

def versions():
    return configuration["scala"].values()
