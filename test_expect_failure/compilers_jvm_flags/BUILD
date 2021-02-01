load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "can_configure_jvm_flags_for_scalac",
    srcs = ["WillNotCompileScalaSinceXmxTooLow.scala"],
    scalac_jvm_flags = ["-Xmx1M"],
)

scala_library(
    name = "can_configure_jvm_flags_for_javac",
    srcs = ["WillNotCompileJavaSinceXmxTooLow.java"],
    javac_jvm_flags = ["-Xmx1M"],
)

scala_library(
    name = "can_configure_jvm_flags_for_javac_via_javacopts",
    srcs = ["WillNotCompileJavaSinceXmxTooLow.java"],
    javacopts = ["-Xmx1M"],
)

exports_files(["args.txt"])

scala_library(
    name = "can_expand_jvm_flags_for_scalac",
    srcs = ["WillNotCompileScalaSinceXmxTooLow.scala"],
    data = [":args.txt"],
    scalac_jvm_flags = ["--ExpandedFlag=$(location :args.txt)"],
)

scala_library(
    name = "can_expand_jvm_flags_for_javac",
    srcs = ["WillNotCompileJavaSinceXmxTooLow.java"],
    data = [":args.txt"],
    javac_jvm_flags = ["$(location :args.txt)"],
)

scala_library(
    name = "can_expand_jvm_flags_for_javac_via_javacopts",
    srcs = ["WillNotCompileJavaSinceXmxTooLow.java"],
    data = [":args.txt"],
    javacopts = ["$(location :args.txt)"],
)
