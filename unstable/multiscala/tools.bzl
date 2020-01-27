load("@rules_jvm_external//:defs.bzl", _maven_install = "maven_install")

def maven_install(**kwargs):
    _maven_install(**kwargs)

def scala_maven_install():
    fail()
