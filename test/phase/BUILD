load(
    "//test/phase:customizability_test.bzl",
    "add_phase_customizability_test_singleton",
    "customizability_test_scala_binary",
    "customizability_test_scala_library",
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

customizability_test_scala_test(
    name = "HelloTest",
    srcs = ["HelloTest.scala"],
    custom_content = "This is custom content in test",
)
