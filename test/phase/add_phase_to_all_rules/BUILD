load(
    "//test/phase/add_phase_to_all_rules:customizability_test.bzl",
    "add_phase_customizability_test_singleton",
    "customizability_test_scala_binary",
    "customizability_test_scala_junit_test",
    "customizability_test_scala_library",
    "customizability_test_scala_library_for_plugin_bootstrapping",
    "customizability_test_scala_macro_library",
    "customizability_test_scala_repl",
    "customizability_test_scala_test",
)

add_phase_customizability_test_singleton(
    name = "phase_customizability_test",
    visibility = ["//visibility:public"],
)

customizability_test_scala_binary(
    name = "HelloBinary",
    srcs = ["HelloBinary.scala"],
    main_class = "scalarules.test.phase.HelloBinary",
)

customizability_test_scala_library(
    name = "HelloLibrary",
    srcs = ["HelloLibrary.scala"],
    custom_content = "This is custom content in library",
)

customizability_test_scala_library_for_plugin_bootstrapping(
    name = "HelloLibraryForPluginBootstrapping",
    srcs = ["HelloLibrary.scala"],
    custom_content = "This is custom content in library_for_plugin_bootstrapping",
)

customizability_test_scala_macro_library(
    name = "HelloMacroLibrary",
    srcs = ["HelloLibrary.scala"],
    custom_content = "This is custom content in macro_library",
)

customizability_test_scala_test(
    name = "HelloTest",
    srcs = ["HelloTest.scala"],
    custom_content = "This is custom content in test",
)

customizability_test_scala_junit_test(
    name = "HelloJunitTest",
    srcs = ["HelloJunitTest.scala"],
    custom_content = "This is custom content in junit_test",
    suffixes = ["Test"],
)

customizability_test_scala_repl(
    name = "HelloRepl",
    srcs = ["HelloLibrary.scala"],
    custom_content = "This is custom content in repl",
)
