load("//scala:scala.bzl", "scala_library","scala_specs2_junit_test")
load("//scala:scala_import.bzl", "scala_import")

#Many jars
scala_import(
  name = "guava_and_commons_lang",
  jars = ["@com_google_guava_guava_21_0//jar:file", "@org_apache_commons_commons_lang_3_5//jar:file"],
)

scala_specs2_junit_test(
    name = "scala_import_exposes_jars",
    srcs = ["ScalaImportExposesJarsTest.scala"],
    deps = [":guava_and_commons_lang"],
    size = "small",
    suffixes = ["Test"],
)

#filter source jars
scala_import(
  name = "cats",
  jars = ["@org_typelevel__cats_core//jar:file"],
)

scala_library(
  name = "source_jar_not_oncp",
  srcs = ["ReferCatsImplicits.scala"],
  deps = [":cats"]
)

##Runtime deps
scala_import(
  name = "indirection_for_transitive_runtime_deps",
  jars = [],
  runtime_deps = [":cats"]
)

scala_import(
  name = "cats_and_guava_and_commons_lang_as_runtime_deps",
  jars = [],
  runtime_deps = [":guava_and_commons_lang", ":indirection_for_transitive_runtime_deps"]
)


scala_specs2_junit_test(
    name = "scala_import_propagates_runtime_deps",
    srcs = ["ScalaImportPropagatesRuntimeDepsTest.scala"],
    runtime_deps = [":cats_and_guava_and_commons_lang_as_runtime_deps"],
    size = "small",
    suffixes = ["Test"],
)

java_import(
  name = "guava_and_commons_lang_java_import",
  jars = ["@com_google_guava_guava_21_0//jar:file", "@org_apache_commons_commons_lang_3_5//jar:file"],
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
    srcs = ["ScalaImportExposesJarsTest.scala"],
    deps = [":guava_and_commons_lang_as_exports"],
    size = "small",
    suffixes = ["Test"],
)

# same as above but deps are routed via java_import instead of
# scala_import
scala_specs2_junit_test(
    name = "scala_import_exports_java_import_targets",
    srcs = ["ScalaImportExposesJarsTest.scala"],
    deps = [":guava_and_commons_lang_as_exports"],
    size = "small",
    suffixes = ["Test"],
)
