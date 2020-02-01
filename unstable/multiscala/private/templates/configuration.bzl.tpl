# -*- mode: python -*-

# load("@io_bazel_rules_scala//unstable/multiscala:macros.bzl", "scala_library")

def _from_json():
    # starlark vs json ...

    true = True
    false = False
    null = None

    return %{STARLARK_STRING}

_configuration = _from_json()

def configuration(): return _configuration

def multiscala_enabled(): return True

def versions():
    return _configuration["scala"].values()

def versioned_name(name, version):
    return name + "_" + version["mvn"]
