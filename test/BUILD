package(default_testonly = 1)

load("//scala:scala.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
    "scala_macro_library",
    "scala_repl",
    "scala_test_suite",
    "scala_library_suite",
    "scala_junit_test",
    "scala_specs2_junit_test")

load("//scala_proto:scala_proto.bzl",
    "scalapb_proto_library")

# The examples below show how to combine Scala and Java rules.
# ScalaBinary is the Scala equivalent of JavaBinary.

java_binary(
    name = "JavaBinary",
    srcs = ["JavaBinary.java"],
    main_class = "scala.test.JavaBinary",
    deps = [
        ":HelloLib",
        ":OtherLib",
        ":Exported",
        ":Runtime",
    ],
    runtime_deps = [
        ":OtherJavaLib",
        "@scala//:scala-library",
    ]
)

java_binary(
    name = "JavaBinary2",
    srcs = ["JavaBinary.java"],
    main_class = "scala.test.JavaBinary",
    deps = [
        ":HelloLib",
        ":OtherLib",
        ":Exported",
        ":Runtime",
    ],
)

scala_binary(
    name = "ScalaBinary",
    srcs = ["ScalaBinary.scala"],
    main_class = "scala.test.ScalaBinary",
    print_compile_time = True,
    deps = [":HelloLib", ":MacroTest"],
)

scala_library(
    name = "HelloLib",
    srcs = ["HelloLib.scala"],
    plugins = ["@org_psywerx_hairyfotr__linter//jar"],
    deps = [
        "OtherJavaLib",
        "OtherLib",
        "MacroTest",
        "Exported"
    ],
)

scala_repl(
    name = "HelloLibRepl",
    deps = [":HelloLib"]
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
    deps = [":HelloLibTest"])

scala_test_suite(
    name = "HelloLibTestSuite",
    size = "small",  # Not a macro, can pass test-specific attributes.
    srcs = glob(["HelloLibTest*.scala"]),
    deps = [
        ":HelloLib",
    ],
)

scala_test(
    name = "TestFilterTests",
    size = "small",
    srcs = glob(["TestFilterTest*.scala"]),
)

scala_repl(
    name = "HelloLibTestRepl",
    deps = [":HelloLibTest"])

scala_library(
    name = "OtherLib",
    srcs = ["OtherLib.scala"],
    deps = ["ExportOnly"],
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

# Test of a grouped library
scala_library_suite(
    name = "SuiteSrcs",
    srcs = glob(["Data*.scala"]),
)

scala_library(
    name = "ConsumeSuite",
    srcs = ["SuiteUsage.scala"],
    deps = ["SuiteSrcs"]
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
    resources = [
        "//test/data:some.txt",
        "//test/src/main/resources/scala/test:byes",
        "//test/src/main/resources/scala/test:hellos",
        ],
)

scala_library(
    name = "ResourcesStripScalaLib",
    srcs = ["src/main/scala/scala/test/ResourcesStripScalaLib.scala"],
    resources = [
        "//test/data:more.txt",
        "//test/data:foo.txt",
        "//test/src/main/resources/scala/test:more-hellos",
        "//test/src/main/resources/scala/test:more-byes",
        "//test/src/main/resources/scala/test:generated-hello",
        ],
    resource_strip_prefix = "test/",
)

scala_binary(
    name = "ScalaLibBinary",
    srcs = ["src/main/scala/scala/test/ScalaLibBinary.scala"],
    main_class = "scala.test.ScalaLibBinary",
    deps = ["ScalaLibResources"],
)

scala_binary(
    name = "ResourcesStripScalaBinary",
    srcs = ["src/main/scala/scala/test/ResourcesStripScalaBinary.scala"],
    main_class = "scala.test.ResourcesStripScalaBinary",
    deps = ["ResourcesStripScalaLib"],
)

# test that a library can depend on a binary:
scala_library(
    name = "lib_to_bin",
    srcs = ["LibToBin.scala"],
    deps = [":ScalaLibBinary"])

scala_repl(
    name = "ScalaLibBinaryRepl",
    deps = [":ScalaLibBinary"])

scala_repl(
    name = "ResourcesStripScalaBinaryRepl",
    deps = [":ResourcesStripScalaBinary"])

scala_repl(
    name = "ReplWithSources",
    srcs = ["A.scala"])

scala_library(
  name = "jar_export",
  exports = ["@com_twitter__scalding_date//jar"]
)

#Mix java scala
scala_library(
    name = "MixJavaScalaLib",
    srcs = glob(["src/main/scala/scala/test/mix_java_scala/*.scala"]) +
           glob(["src/main/scala/scala/test/mix_java_scala/*.java"]),
    jvm_flags = ["-Xms1G", "-Xmx4G"],
)
#needed to test java sources are compiled
scala_binary(
    name = "MixJavaScalaLibBinary",
    srcs = ["src/main/scala/scala/test/MixJavaScalaLibBinary.scala"],
    main_class = "scala.test.MixJavaScalaLibBinary",
    deps = ["MixJavaScalaLib"],
)

#Mix java scala (srcjar), much like above only the java is provided via srcjar
scala_library(
    name = "MixJavaScalaSrcjarLib",
    srcs = glob([
      "src/main/scala/scala/test/mix_java_scala/*.scala",
      # srcjar created with `jar -cfM Baz.srcjar Baz.java`
      "src/main/scala/scala/test/mix_java_scala/*.srcjar"
    ]),
    jvm_flags = ["-Xms1G", "-Xmx4G"],
)
#needed to test java sources are compiled
scala_binary(
    name = "MixJavaScalaSrcjarLibBinary",
    srcs = ["src/main/scala/scala/test/MixJavaScalaLibBinary.scala"],
    main_class = "scala.test.MixJavaScalaLibBinary",
    deps = ["MixJavaScalaSrcjarLib"],
)

scala_binary(
    name = "JavaOnlySources",
    srcs = ["src/main/scala/scala/test/only_java/Alpha.java"],
    main_class = "scala.test.Alpha",
)

scala_library(
    name = "JUnitCompileTimeDep",
    srcs = ["src/main/scala/scala/test/junit/support/JUnitCompileTimeDep.scala"],
)
scala_library(
    name = "JUnitRuntimeDep",
    srcs = ["src/main/scala/scala/test/junit/support/JUnitRuntimeDep.scala"],
)
scala_junit_test(
    name = "JunitTestWithDeps",
    srcs = ["src/main/scala/scala/test/junit/JunitTests.scala"],
    suffixes = ["Test"],
    size = "small",
    deps = [":JUnitCompileTimeDep"],
    runtime_deps = [":JUnitRuntimeDep"],
    jvm_flags = ["-XX:HeapDumpPath=/some/custom/path"],
)
scala_junit_test(
    name = "JunitMultipleSuffixes",
    srcs = ["src/main/scala/scala/test/junit/JunitMultipleSuffixes.scala"],
    size = "small",
    suffixes = ["E2E","IT"],
    print_discovered_classes = True
)
scala_junit_test(
    name = "JunitMultiplePrefixes",
    srcs = ["src/main/scala/scala/test/junit/JunitMultiplePrefixes.scala"],
    size = "small",
    prefixes = ["Test","OtherCustomPrefix"],
    print_discovered_classes = True
)
scala_junit_test(
    name = "JunitPrefixesAndSuffixes",
    srcs = ["src/main/scala/scala/test/junit/JunitMultipleSuffixes.scala",
            "src/main/scala/scala/test/junit/JunitMultiplePrefixes.scala"],
    size = "small",
    suffixes = ["E2E"],
    prefixes = ["Test"],
    print_discovered_classes = True
)

scala_junit_test(
    name = "JunitJavaTest",
    srcs = ["src/main/scala/scala/test/junit/JunitJavaTest.java"],
    suffixes = ["Test"],
    size = "small",
)

scala_specs2_junit_test(
    name = "Specs2Tests",
    srcs = ["src/main/scala/scala/test/junit/specs2/Specs2Tests.scala"],
    deps = [":JUnitCompileTimeDep"],
    size = "small",
    suffixes = ["Test"],
)

# Make sure scala_binary works in test environment
[sh_test(
    name = "Run" + binary,
    srcs = ["test_binary.sh"],
    args = ["$(location %s)" % binary],
    data = [":%s" % binary],
) for binary in [
    "JavaBinary",
    "JavaBinary2",
    "ScalaBinary",
    "ScalaLibBinary",
    "ResourcesStripScalaBinary",
    "MixJavaScalaLibBinary",
    "JavaOnlySources",
    "ScalaBinary_dependent_on_binary_with_java"
]]

# Make sure scala_binary works in genrule environment
genrule(
    name = "ScalaBinaryInGenrule",
    tools = [":ScalaBinary"],
    outs = ["scala_binary_out.txt"],
    cmd = "$(location :ScalaBinary) > $@",
)

sh_test(
    name = "TestScalaBinaryInGenrule",
    srcs = ["test_binary.sh"],
    args = ["cat $(location :ScalaBinaryInGenrule)"],
    data = [":ScalaBinaryInGenrule"],
)

scala_specs2_junit_test(
    name = "data_location_expansion",
    srcs = ["src/main/scala/scala/test/location_expansion/LocationExpansionTest.scala"],
    size = "small",
    suffixes = ["Test"],
    data = ["//src/java/com/google/devtools/build/lib:worker"],
    jvm_flags = ["-Dlocation.expanded=$(location //src/java/com/google/devtools/build/lib:worker)"],
)

scala_junit_test(
    name = "JunitFiltersAbstractClassesAndInterfaces",
    srcs = ["src/main/scala/scala/test/junit/JunitAbstractClassAndInterface.scala"],
    size = "small",
    suffixes = ["Test"],
    print_discovered_classes = True
)

scala_junit_test(
    name = "JunitFiltersInnerClasses",
    srcs = ["src/main/scala/scala/test/junit/JunitInnerClass.scala"],
    size = "small",
    prefixes = ["Test"],
    print_discovered_classes = True
)

scala_junit_test(
    name = "JunitFiltersClassesWithoutTests",
    srcs = ["src/main/scala/scala/test/junit/JunitNoTests.scala"],
    size = "small",
    suffixes = ["Test"],
    print_discovered_classes = True
)

scala_junit_test(
    name = "JunitIncludesClassesWithTestsFromParent",
    srcs = ["src/main/scala/scala/test/junit/JunitIncludesTestHierarchies.scala"],
    size = "small",
    suffixes = ["Test"],
    print_discovered_classes = True
)

scala_junit_test(
    name = "JunitIncludesClassesWithRunWith",
    srcs = ["src/main/scala/scala/test/junit/JunitIncludesRunWith.scala"],
    size = "small",
    suffixes = ["Test"],
    print_discovered_classes = True
)

scala_junit_test(
    name = "JunitFilterTest",
    size = "small",
    srcs = ["src/main/scala/scala/test/junit/FilterTest.scala"],
    print_discovered_classes = True,
    suffixes = ["Test"],
)

scala_library(
    name = "filesWithUtf8",
    srcs = ["src/main/scala/scala/test/utf8/JavaClassWithUtf8.java",
            "src/main/scala/scala/test/utf8/ScalaClassWithUtf8.scala"]
    )

# make sure making a fat jar strips signatures
java_import(
    name = "fakejar",
    jars = ["fake_sig.jar"])

scala_binary(
    name = "ScalaBinary_with_fake",
    srcs = ["ScalaBinary.scala"],
    main_class = "scala.test.ScalaBinary",
    deps = [":HelloLib", ":MacroTest", ":fakejar"],
)

py_binary(
    name = "jar_lister",
    srcs = ["jar_lister.py"]
)

sh_test(
  name = "no_sig",
  srcs = ["no_sigs.sh"],
  args = ["$(location //test:jar_lister)", "$(location //test:ScalaBinary_with_fake_deploy.jar)"],
  data = [":ScalaBinary_with_fake_deploy.jar", ":jar_lister"],
)

scala_binary(
    name = "ScalaBinary_with_service_manifest_srcs",
    srcs = ["A.scala"],
    main_class = "scala.test.A",
    deps = ["//test/example_jars:example_jar1", "//test/example_jars:example_jar2"]
)

scala_binary(
    name = "ScalaBinary_dependent_on_binary_with_java",
    srcs = ["src/main/scala/scala/test/BinaryDependentOnJava.scala"],
    main_class = "scala.test.BinaryDependentOnJava",
    deps = [":JavaOnlySources"],
)

scala_library(
    name = "lib_with_scala_proto_dep",
    srcs = ["TestServer.scala"],
    deps = ["//test/proto:test_proto"]
)

scala_binary(
    name = "test_scala_proto_server",
    main_class = "test.proto.TestServer",
    deps = [":lib_with_scala_proto_dep"]
)

scalapb_proto_library(
    name = "test_proto_scala_dep",
    deps = ["//test/proto:test2", ":HelloLib"],
    visibility = ["//visibility:public"],
)
