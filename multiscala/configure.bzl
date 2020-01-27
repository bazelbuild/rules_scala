load("@io_bazel_rules_scala_configuration//:configuration.bzl", _configuration = "configuration")
load("@io_bazel_rules_scala//multiscala:toolchains.bzl", _toolchain_label = "toolchain_label")

def multiscala_configure():
    _maybe_register_default_toolchains()

def _maybe_default():
    return _configuration["scala"][_configuration["default"]] if "default" in _configuration else None

def _maybe_register_default_toolchains():
    version = _maybe_default()
    if version:
        for toolchain in [
                # "bootstrap",
                "scala",
                # "scalatest"
        ]:
            native.register_toolchains("@io_bazel_rules_scala//multiscala:"+_toolchain_label(toolchain, version))
