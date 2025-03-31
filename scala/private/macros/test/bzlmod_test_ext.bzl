"""Used by test/shell/test_bzlmod_helpers.sh to test bzlmod.bzl.

Defines a module extension with two tag classes:

- `single_test_tag`: Contains three `attr.string` fields with nonempty default
  values. Should have at most one regular instance and one `dev_dependency`
  instance. Used to test `single_tag_values`.

- `repeated_test_tag`: Contains a mandatory `key` attr, one `required` attr, and
  one `optional` attr. Used to test `repeated_tag_values`.

Generates `@test_tag_values//:results.bzl` from `_test_tag_results_bzl_template`.
`BUILD.bzlmod_test` imports the following symbols from this generated file:

- For `single_test_tag`: the `FIRST`, `SECOND`, and `THIRD` string constants
- For `repeated_test_tag`: the `REPEATED` dict of dicts
"""

load(
    "@rules_scala//scala/private:macros/bzlmod.bzl",
    "repeated_tag_values",
    "root_module_tags",
    "single_tag_values",
)

visibility("private")

_single_test_tag_defaults = {
    "first": "foo",
    "second": "bar",
    "third": "baz",
}

_single_test_tag_attrs = {
    k: attr.string(default = v)
    for k, v in _single_test_tag_defaults.items()
}

_repeated_test_tag_attrs = {
    "unique_key": attr.string(mandatory = True),
    "required": attr.string(mandatory = True),
    "optional": attr.string(),
}

_tag_classes = {
    "single_test_tag": tag_class(attrs = _single_test_tag_attrs),
    "repeated_test_tag": tag_class(attrs = _repeated_test_tag_attrs),
}

_test_tag_results_bzl_template = """
FIRST = "{first}"
SECOND = "{second}"
THIRD = "{third}"
REPEATED = {repeated}
"""

def _test_tag_results_repo_impl(rctx):
    rctx.file("BUILD")
    rctx.file(
        "results.bzl",
        _test_tag_results_bzl_template.format(**rctx.attr.test_tag_values),
    )

_test_tag_results_repo = repository_rule(
    implementation = _test_tag_results_repo_impl,
    attrs = {
        "test_tag_values": attr.string_dict(mandatory = True),
    },
)

def _test_ext_impl(mctx):
    root_tags = root_module_tags(mctx, _tag_classes.keys())
    single_values = single_tag_values(
        mctx,
        root_tags.single_test_tag,
        _single_test_tag_defaults,
    )
    repeated_values = repeated_tag_values(
        root_tags.repeated_test_tag,
        _repeated_test_tag_attrs,
    )

    _test_tag_results_repo(
        name = "test_tag_values",
        test_tag_values = single_values | {"repeated": str(repeated_values)},
    )

test_ext = module_extension(
    implementation = _test_ext_impl,
    tag_classes = _tag_classes,
)
