load(
    "//test/phase/add_to_all_rules:phase_add_to_all_rules_test.bzl",
    "add_to_all_rules_scala_binary",
    "add_to_all_rules_scala_junit_test",
    "add_to_all_rules_scala_library",
    "add_to_all_rules_scala_library_for_plugin_bootstrapping",
    "add_to_all_rules_scala_macro_library",
    "add_to_all_rules_scala_repl",
    "add_to_all_rules_scala_test",
    "add_to_all_rules_singleton",
)

add_to_all_rules_singleton(
    name = "phase_add_to_all_rules",
    visibility = ["//visibility:public"],
)

add_to_all_rules_scala_binary(
    name = "PhaseBinary",
    srcs = ["PhaseBinary.scala"],
    main_class = "scalarules.test.phase.add_to_all_rules.PhaseBinary",
)

add_to_all_rules_scala_library(
    name = "PhaseLibrary",
    srcs = ["PhaseLibrary.scala"],
    custom_content = "This is custom content in library",
)

add_to_all_rules_scala_library_for_plugin_bootstrapping(
    name = "PhaseLibraryForPluginBootstrapping",
    srcs = ["PhaseLibrary.scala"],
    custom_content = "This is custom content in library_for_plugin_bootstrapping",
)

add_to_all_rules_scala_macro_library(
    name = "PhaseMacroLibrary",
    srcs = ["PhaseLibrary.scala"],
    custom_content = "This is custom content in macro_library",
)

add_to_all_rules_scala_test(
    name = "PhaseTest",
    srcs = ["PhaseTest.scala"],
    custom_content = "This is custom content in test",
)

add_to_all_rules_scala_junit_test(
    name = "PhaseJunitTest",
    srcs = ["PhaseJunitTest.scala"],
    custom_content = "This is custom content in junit_test",
    suffixes = ["Test"],
)

add_to_all_rules_scala_repl(
    name = "PhaseRepl",
    srcs = ["PhaseLibrary.scala"],
    custom_content = "This is custom content in repl",
)
