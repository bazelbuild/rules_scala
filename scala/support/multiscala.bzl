load("@io_bazel_rules_scala_configuration//:configuration.bzl",
     _multiscala_enabled = "multiscala_enabled",
)

def load_multiscala():
    return
    if _multiscala_enabled():
        fail("implement me")
