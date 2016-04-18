load("//scala:scala.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
    "scala_macro_library",
    "scala_export_to_java")

# The examples below show how to combine Scala and Java rules.
# ScalaBinary is the Scala equivalent of JavaBinary.

java_binary(
    name = "JavaBinary",
    srcs = ["JavaBinary.java"],
    main_class = "scala.test.JavaBinary",
    deps = [":lib_import"],
)

# TODO(bazel-team): Allow java rules to depend directly on scala_library.
# For now, we have to use a java_import proxy.
java_import(
    name = "lib_import",
    # these are the outputs of the scala_library targets
    jars = [":HelloLib_deploy.jar",
            "OtherLib_deploy.jar",
            "Exported_deploy.jar",
            "Runtime_deploy.jar",
           ],
    runtime_deps = ["org_scala_lang__scala_library", "OtherJavaLib"]
)

scala_export_to_java(
    name = "lib_import_2",
    exports = [":HelloLib",
               "OtherLib",
               "Exported",
               "Runtime",
              ],
    runtime_deps = ["OtherJavaLib"],
)

java_import(
    name = "org_scala_lang__scala_library",
    jars = ["@scala//:lib/scala-library.jar"]
)

scala_binary(
    name = "ScalaBinary",
    srcs = ["ScalaBinary.scala"],
    main_class = "scala.test.ScalaBinary",
    deps = [":HelloLib", ":MacroTest"],
)

scala_library(
    name = "HelloLib",
    srcs = ["HelloLib.scala"],
    deps = [
        "OtherJavaLib",
        "OtherLib",
        "MacroTest"
    ],
)

scala_test(
    name = "HelloLibTest",
    size = "small",  # Not a macro, can pass test-specific attributes.
    srcs = ["HelloLibTest.scala"],
    deps = [
        ":HelloLib",
    ],
)

scala_library(
    name = "a",
    srcs = ["A.scala"]
)

scala_library(
    name = "b",
    exports = [":a"],
)

scala_library(
    name = "c",
    deps = [":b"],
)

scala_library(
    name = "d",
    deps = [":c"],
    srcs = ["D.scala"],
)

scala_library(
    name = "OtherLib",
    srcs = ["OtherLib.scala"],
    exports = ["ExportOnly"],  # test of exported target
)

# Test of library without src
scala_library(
    name = "ExportOnly",
    exports = [ "Exported" ],
)

scala_library(
    name = "Exported",
    srcs = ["Exported.scala"],
    runtime_deps = ["Runtime"],
)

scala_macro_library(
  name = "MacroTest",
  srcs = ["MacroTest.scala"]
)

scala_library(
    name = "Runtime",
    srcs = ["Runtime.scala"],
)

java_library(
    name = "OtherJavaLib",
    srcs = ["OtherJavaLib.java"],
)

scala_library(
    name = "ScalaLibResources",
    srcs = ["src/main/scala/scala/test/ScalaLibResources.scala"],
    resources = ["src/main/resources/scala/test/hellos", "src/main/resources/scala/test/byes"],
)

scala_binary(
    name = "ScalaLibBinary",
    srcs = ["src/main/scala/scala/test/ScalaLibBinary.scala"],
    main_class = "scala.test.ScalaLibBinary",
    deps = ["ScalaLibResources"],
)

scala_library(
  name = "jar_export",
  exports = ["@com_twitter__scalding_date//jar"]
)
