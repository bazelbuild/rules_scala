load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test")
load("//scala:scala_import.bzl", "scala_import")

#Many jars
scala_import(
    name = "guava_and_commons_lang",
    jars = [
        "@com_google_guava_guava_21_0_with_file//jar:file",
        "@org_apache_commons_commons_lang_3_5//jar:file",
    ],
)

# Jars as files
scala_import(
    name = "relate",
    jars = [
        "relate_2.11-2.1.1.jar",
    ],
)

scala_specs2_junit_test(
    name = "scala_import_exposes_jars",
    size = "small",
    srcs = ["ScalaImportExposesJarsTest.scala"],
    suffixes = ["Test"],
    deps = [":guava_and_commons_lang"],
)

scala_specs2_junit_test(
    name = "scala_import_exposes_file_jars",
    size = "small",
    srcs = ["ScalaImportExposesFileJarsTest.scala"],
    suffixes = ["Test"],
    deps = [":relate"],
)

#filter source jars
scala_import(
    name = "cats",
    jars = ["@org_typelevel__cats_core//jar:file"],
)

scala_library(
    name = "source_jar_not_oncp",
    srcs = ["ReferCatsImplicits.scala"],
    deps = [":cats"],
)

##Runtime deps
scala_import(
    name = "indirection_for_transitive_runtime_deps",
    jars = [],
    runtime_deps = [":cats"],
)

scala_import(
    name = "cats_and_guava_and_commons_lang_as_runtime_deps",
    jars = [],
    runtime_deps = [
        ":guava_and_commons_lang",
        ":indirection_for_transitive_runtime_deps",
    ],
)

scala_specs2_junit_test(
    name = "scala_import_propagates_runtime_deps",
    size = "small",
    srcs = ["ScalaImportPropagatesRuntimeDepsTest.scala"],
    suffixes = ["Test"],
    runtime_deps = [":cats_and_guava_and_commons_lang_as_runtime_deps"],
)

java_import(
    name = "guava_and_commons_lang_java_import",
    jars = [
        "@com_google_guava_guava_21_0_with_file//jar:file",
        "@org_apache_commons_commons_lang_3_5//jar:file",
    ],
)

#Exports
scala_import(
    name = "guava_and_commons_lang_as_exports",
    exports = [":guava_and_commons_lang"],
)

# we're testing the scenario:
# jar <- java_import <- scala_import (exports) <- scala_specs2_junit_test
# see for details https://github.com/bazelbuild/rules_scala/issues/354
scala_import(
    name = "guava_and_commons_lang_as_exports_from_java_import",
    exports = [":guava_and_commons_lang_java_import"],
)

scala_specs2_junit_test(
    name = "scala_import_exports_targets",
    size = "small",
    srcs = ["ScalaImportExposesJarsTest.scala"],
    suffixes = ["Test"],
    deps = [":guava_and_commons_lang_as_exports"],
)

# same as above but deps are routed via java_import instead of
# scala_import
scala_specs2_junit_test(
    name = "scala_import_exports_java_import_targets",
    size = "small",
    srcs = ["ScalaImportExposesJarsTest.scala"],
    suffixes = ["Test"],
    deps = [":guava_and_commons_lang_as_exports"],
)
