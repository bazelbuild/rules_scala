"""
This test makes sure custom default attributes can be defined for rules created with make_scala_test
"""

load(
    "//scala:advanced_usage/scala.bzl",
    _make_scala_test = "make_scala_test",
)

# Inputs for customizable default attributes of make_scala_test
custom_default_attrs = {
    "reporter_class": attr.string(
        default = "test.scala_test.CustomReporter",
    ),
}

custom_default_attrs_scala_test = _make_scala_test(attrs = custom_default_attrs)
