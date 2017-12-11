load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala.bzl", "scala_library")

scala_toolchain(
    name = "failing_scala_toolchain",
    scalacopts = ["-Ywarn-unused","-Xfatal-warnings"]
)

scala_library(
    name = "failing_build",
    srcs = ["HelloWorld.scala"]
)