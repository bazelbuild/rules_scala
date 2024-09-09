load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "can_configure_jvm_flags_for_javac_via_javacopts",
    srcs = ["WillNotCompileSinceJavaToolchainAddsAnInvalidJvmFlag.java"],
)

scala_library(
    name = "can_override_default_toolchain_flags_for_javac_via_javacopts",
    srcs = ["WillNotCompileSinceJavaToolchainAddsAnInvalidJvmFlag.java"],
    javacopts = ["-target InvalidTarget"],
)
