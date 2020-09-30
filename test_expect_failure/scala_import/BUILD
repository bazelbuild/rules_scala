load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test")
load("//scala:scala_import.bzl", "scala_import")

#deps, transitive_deps and propagation of deps as transitive_runtime_deps
#also labels handling- transitive and transitive-transitive

scala_import(
    name = "dummy_dependency_to_trigger_create_provider_transitive_compile_jar_usage",
    testonly = True,
    jars = ["@org_psywerx_hairyfotr__linter//jar"],
)

scala_import(
    name = "guava",
    testonly = True,
    jars = ["@com_google_guava_guava_21_0_with_file//jar"],
    deps = [":dummy_dependency_to_trigger_create_provider_transitive_compile_jar_usage"],
)

scala_import(
    name = "cats",
    testonly = True,
    jars = ["@org_typelevel__cats_core//jar"],
)

scala_import(
    name = "indirection_for_transitive_compile_deps",
    testonly = True,
    jars = [],
    deps = [":cats"],
)

scala_import(
    name = "commons_lang_as_imported_jar_cats_and_guava_as_compile_deps",
    testonly = True,
    jars = ["@org_apache_commons_commons_lang_3_5//jar"],
    deps = [
        ":guava",
        ":indirection_for_transitive_compile_deps",
    ],
)

scala_specs2_junit_test(
    name = "scala_import_propagates_compile_deps",
    size = "small",
    srcs = ["ScalaImportPropagatesCompileDepsTest.scala"],
    suffixes = ["Test"],
    deps = [":commons_lang_as_imported_jar_cats_and_guava_as_compile_deps"],
)

scala_library(
    name = "leaf_for_scala_import_passes_labels_of_direct_deps",
    srcs = ["LeafScalaImportPassesLabelsDirectDeps.scala"],
    deps = [":middle_for_scala_import_passes_labels_of_direct_deps"],
)

scala_import(
    name = "middle_for_scala_import_passes_labels_of_direct_deps",
    jars = [],
    deps = [":root_for_scala_import_passes_labels_of_direct_deps"],
)

scala_library(
    name = "root_for_scala_import_passes_labels_of_direct_deps",
    srcs = ["RootScalaImportPassesLabelsDirectDeps.scala"],
)
