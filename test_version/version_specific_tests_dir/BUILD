package(default_testonly = 1)

load(
    "@io_bazel_rules_scala//scala:scala.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
    "scala_macro_library",
    "scala_repl",
    "scala_test_suite",
    "scala_library_suite",
    "scala_junit_test",
    "scala_specs2_junit_test",
)
load(
    "@io_bazel_rules_scala//scala_proto:scala_proto.bzl",
    "scalapb_proto_library",
)

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

# test that a library can depend on a test:
scala_library(
    name = "lib_to_test",
    srcs = ["LibToTest.scala"],
    deps = [":HelloLibTest"],
)

scala_test(
    name = "TestFilterTests",
    size = "small",
    srcs = glob(["TestFilterTest*.scala"]),
)

scala_repl(
    name = "HelloLibTestRepl",
    deps = [":HelloLibTest"],
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

scala_repl(
    name = "ReplWithSources",
    srcs = ["A.scala"],
)

#Mix java scala
scala_library(
    name = "MixJavaScalaLib",
    srcs = glob(["src/main/scala/scalarules/test/mix_java_scala/*.scala"]) + glob([
        "src/main/scala/scalarules/test/mix_java_scala/*.java",
    ]),
    jvm_flags = [
        "-Xms1G",
        "-Xmx4G",
    ],
)

#needed to test java sources are compiled
scala_binary(
    name = "MixJavaScalaLibBinary",
    srcs = ["src/main/scala/scalarules/test/MixJavaScalaLibBinary.scala"],
    main_class = "scalarules.test.MixJavaScalaLibBinary",
    deps = ["MixJavaScalaLib"],
)

#Mix java scala (srcjar), much like above only the java is provided via srcjar
scala_library(
    name = "MixJavaScalaSrcjarLib",
    srcs = glob([
        "src/main/scala/scalarules/test/mix_java_scala/*.scala",
        # srcjar created with `jar -cfM Baz.srcjar Baz.java`
        "src/main/scala/scalarules/test/mix_java_scala/*.srcjar",
    ]),
    jvm_flags = [
        "-Xms1G",
        "-Xmx4G",
    ],
)

#needed to test java sources are compiled
scala_binary(
    name = "MixJavaScalaSrcjarLibBinary",
    srcs = ["src/main/scala/scalarules/test/MixJavaScalaLibBinary.scala"],
    main_class = "scalarules.test.MixJavaScalaLibBinary",
    deps = ["MixJavaScalaSrcjarLib"],
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
    "MixJavaScalaSrcjarLibBinary",
    "ScalaBinary",
]]


scala_junit_test(
    name = "JunitCustomRunner",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitCustomRunnerTest.scala"],
    suffixes = ["Test"],
    deps = [":customJunitRunner"],
)

scala_junit_test(
    name = "JunitIncludesClassesWithRunWith",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitIncludesRunWith.scala"],
    print_discovered_classes = True,
    suffixes = ["Test"],
)

scala_library(
    name = "customJunitRunner",
    srcs = ["src/main/scala/scalarules/test/junit/JunitCustomRunner.java"],
    deps = ["//external:io_bazel_rules_scala/dependency/junit/junit"],
)

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

scalapb_proto_library(
    name = "test_proto_scala_dep",
    visibility = ["//visibility:public"],
    deps = [
        ":HelloLib",
        "//proto:test2",
    ],
)

