SCALA_BUILD_FILE_2_11 = """
# scala.BUILD
load("@io_bazel_rules_scala//scala:providers.bzl",
     _declare_scala_worker = "declare_scala_worker",
)
java_import(
    name = "scala-xml",
    jars = ["lib/scala-xml_2.11-1.0.5.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-parser-combinators",
    jars = ["lib/scala-parser-combinators_2.11-1.0.4.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-library",
    jars = ["lib/scala-library.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-compiler",
    jars = ["lib/scala-compiler.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-reflect",
    jars = ["lib/scala-reflect.jar"],
    visibility = ["//visibility:public"],
)

_declare_scala_worker(
    name = "scala",
    visibility = ["//visibility:public"],
    major_version = "2.11",
    scalac = "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac:scalac_2.11",
    scalalib = "//:scala-library",
    scalareflect = "//:scala-reflect",
    scalaxml = "//:scala-xml",
    scalacompiler = "//:scala-compiler",
    scalatest = ["@scalatest_2_11//jar", "@scalactic_2_11//jar"],
    scalatest_runner = "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scala_test:runner_2.11.jar",
)
"""


SCALA_BUILD_FILE_2_12 = """
# scala.BUILD
load("@io_bazel_rules_scala//scala:providers.bzl",
     _declare_scala_worker = "declare_scala_worker",
)
java_import(
    name = "scala-xml",
    jars = ["lib/scala-xml_2.12-1.0.6.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-parser-combinators",
    jars = ["lib/scala-parser-combinators_2.12-1.0.7.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-library",
    jars = ["lib/scala-library.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-compiler",
    jars = ["lib/scala-compiler.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-reflect",
    jars = ["lib/scala-reflect.jar"],
    visibility = ["//visibility:public"],
)

_declare_scala_worker(
    name = "scala_2_12",
    major_version = "2.12",
    scalac = "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac:scalac_2.12",
    scalalib = "@scala_2_12//:scala-library",
    scalareflect = "@scala_2_12//:scala-reflect",
    scalaxml = "//:scala-xml",
    scalacompiler = "@scala_2_12//:scala-compiler",
    scalatest = ["@scalatest_2_12//jar", "@scalactic_2_12//jar"],
    scalatest_runner = "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scala_test:runner_2.12.jar",
    visibility = ["//visibility:public"],
)
"""
