"""post-configuration generation, complete other actions based on the resulting configuration"""

load(
    "@io_bazel_rules_scala//unstable/multiscala:configuration.bzl",
    _native_toolchain_label = "native_toolchain_label",
)
load(
    "@io_bazel_rules_scala_configuration//:configuration.bzl",
    _configuration = "configuration",
)

def multiscala_configure():
    _maybe_register_default_toolchains()

def _maybe_default():
    return _configuration()["scala"][_configuration()["default"]] if "default" in _configuration() else None

def _maybe_register_default_toolchains():
    version = _maybe_default()
    if version:
        for toolchain in [
            "bootstrap",
            "scala",
            "scala_test",
        ]:
            native.register_toolchains(_native_toolchain_label(toolchain, version["mvn"]))
