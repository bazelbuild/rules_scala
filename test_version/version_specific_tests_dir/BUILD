load("@rules_java//java:defs.bzl", "java_binary", "java_library")
load(
    "@io_bazel_rules_scala//scala:scala.bzl",
    "scala_binary",
    "scala_junit_test",
    "scala_library",
    "scala_macro_library",
    "scala_repl",
    "scala_specs2_junit_test",
    "scala_test",
)

package(default_testonly = 1)

# The examples below show how to combine Scala and Java rules.
# ScalaBinary is the Scala equivalent of JavaBinary.

java_binary(
    name = "JavaBinary",
    srcs = ["JavaBinary.java"],
    main_class = "scalarules.test.JavaBinary",
    deps = [
        ":Exported",
        ":HelloLib",
        ":OtherLib",
        ":Runtime",
    ],
)

scala_binary(
    name = "ScalaBinary",
    srcs = ["ScalaBinary.scala"],
    main_class = "scalarules.test.ScalaBinary",
    print_compile_time = True,
    deps = [
        ":HelloLib",
        ":MacroTest",
    ],
)

scala_library(
    name = "HelloLib",
    srcs = ["HelloLib.scala"],
    deps = [
        "Exported",
        "MacroTest",
        "OtherJavaLib",
        "OtherLib",
    ],
)

scala_repl(
    name = "HelloLibRepl",
    deps = [":HelloLib"],
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
    name = "OtherLib",
    srcs = ["OtherLib.scala"],
    deps = ["ExportOnly"],
)

# Test of library without src
scala_library(
    name = "ExportOnly",
    exports = ["Exported"],
)

scala_library(
    name = "Exported",
    srcs = ["Exported.scala"],
    runtime_deps = ["Runtime"],
)

scala_macro_library(
    name = "MacroTest",
    srcs = ["MacroTest.scala"],
)

scala_library(
    name = "Runtime",
    srcs = ["Runtime.scala"],
)

java_library(
    name = "OtherJavaLib",
    srcs = ["OtherJavaLib.java"],
)

#Mix java scala
scala_library(
    name = "MixJavaScalaLib",
    srcs = glob(["src/main/scala/scalarules/test/mix_java_scala/*.scala"]) + glob([
        "src/main/scala/scalarules/test/mix_java_scala/*.java",
    ]),
    #    disabled due to Travis CI memory failure
    #    scalac_jvm_flags = [
    #        "-Xms1G",
    #        "-Xmx4G",
    #    ],
)

#needed to test java sources are compiled
scala_binary(
    name = "MixJavaScalaLibBinary",
    srcs = ["src/main/scala/scalarules/test/MixJavaScalaLibBinary.scala"],
    main_class = "scalarules.test.MixJavaScalaLibBinary",
    deps = ["MixJavaScalaLib"],
)

scala_library(
    name = "JUnitCompileTimeDep",
    srcs = ["src/main/scala/scalarules/test/junit/support/JUnitCompileTimeDep.scala"],
)

scala_library(
    name = "JUnitRuntimeDep",
    srcs = ["src/main/scala/scalarules/test/junit/support/JUnitRuntimeDep.scala"],
)

scala_junit_test(
    name = "JunitTestWithDeps",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitTests.scala"],
    jvm_flags = ["-XX:HeapDumpPath=/some/custom/path"],
    suffixes = ["Test"],
    runtime_deps = [":JUnitRuntimeDep"],
    deps = [":JUnitCompileTimeDep"],
)

scala_specs2_junit_test(
    name = "Specs2Tests",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/specs2/Specs2Tests.scala"],
    print_discovered_classes = True,
    suffixes = ["Test"],
    deps = [":JUnitCompileTimeDep"],
)

# Make sure scala_binary works in test environment
[sh_test(
    name = "Run" + "".join([binary[idx] if binary[idx].isalnum() else "_" for idx in range(len(binary))]),
    srcs = ["test_binary.sh"],
    args = ["$(location %s)" % binary],
    data = [binary if (":" in binary) else (":%s" % binary)],
) for binary in [
    "JavaBinary",
    "MixJavaScalaLibBinary",
    "ScalaBinary",
    "hello211",
    "hello212",
    "hello213",
    "hello31",
    "hello32",
    "hello33",
]]

scala_library(
    name = "lib_with_scala_proto_dep",
    srcs = ["TestServer.scala"],
    deps = ["//proto:test_proto"],
)

scala_binary(
    name = "test_scala_proto_server",
    main_class = "test.proto.TestServer",
    deps = [":lib_with_scala_proto_dep"],
)

scala_binary(
    name = "hello211",
    scala_version = "2.11.12",
    main_class = "scalarules.test.versions.Hello211",
    srcs = ["versions/Hello211.scala"],
)

scala_binary(
    name = "hello212",
    scala_version = "2.12.18",
    main_class = "scalarules.test.versions.Hello212",
    srcs = ["versions/Hello212.scala"],
)

scala_binary(
    name = "hello213",
    scala_version = "2.13.12",
    main_class = "scalarules.test.versions.Hello213",
    srcs = ["versions/Hello213.scala"],
)

scala_binary(
    name = "hello31",
    scala_version = "3.1.0",
    main_class = "scalarules.test.versions.hello31",
    srcs = ["versions/Hello31.scala"],
)

scala_binary(
    name = "hello32",
    scala_version = "3.2.1",
    main_class = "scalarules.test.versions.hello32",
    srcs = ["versions/Hello32.scala"],
)

scala_binary(
    name = "hello33",
    scala_version = "3.3.1",
    main_class = "scalarules.test.versions.hello33",
    srcs = ["versions/Hello33.scala"],
)
