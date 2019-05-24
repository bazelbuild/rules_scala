#
# Coverage Replacements are a mapping of normal compiled artifacts to
# instrumented compiled artifacts.
#
# The intention is that the final test runner inspects the test
# classpath and replaces artifacts by any mappings found in the
# `replacements` field.
#
# Rules producing replacement artifacts should _not_ link the
# replacement files as any of the default outputs via DefaultInfo,
# JavaInfo, etc. This way, actions producing the replacement artifacts
# will be executed on an as needed basis.
#
# Coverage Replacements use a provider and a helper aspect to
# aggregate replacements files across the dependency graph.
#
# Under the hood, two providers are needed because Bazel doesn't allow
# duplicate providers.
#

_CoverageReplacements = provider(
    fields = {
        "replacements": "hash of files to swap out",
    },
)

_CombinedCoverageReplacements = provider(
    fields = {
        "replacements": "hash of files to swap out",
    },
)

# the attributes used to form the dependency graph that we'll fold
# over for our aggregation
_dependency_attributes = [
    "deps",
    "exports",
]

def _combine(*entriess, base = {}):
    return _CombinedCoverageReplacements(replacements = _dicts_add(base, *(
        [
            entry[_CoverageReplacements].replacements
            for entries in entriess
            for entry in entries
            if _CoverageReplacements in entry
        ] + [
            entry[_CombinedCoverageReplacements].replacements
            for entries in entriess
            for entry in entries
            if _CombinedCoverageReplacements in entry
        ]
    )))

def _from_ctx(ctx, base = {}):
    return _combine(
        base = base,
        *[getattr(ctx.attr, name, []) for name in _dependency_attributes]
    )

def _aspect_impl(target, ctx):
    if JavaInfo in target and _is_enabled(ctx):
        return [_from_ctx(ctx.rule)]
    else:
        return []

_aspect = aspect(
    attr_aspects = _dependency_attributes,
    implementation = _aspect_impl,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
)

def _is_enabled(ctx):
    if "@io_bazel_rules_scala//scala:toolchain_type" not in ctx.toolchains:
        return False
    else:
        return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].enable_code_coverage_aspect == "on"

coverage_replacements_provider = struct(
    aspect = _aspect,
    combine = _combine,
    create = _CoverageReplacements,
    dependency_attributes = _dependency_attributes,
    from_ctx = _from_ctx,
    is_enabled = _is_enabled,
)

# from bazel's skylib
def _dicts_add(*dictionaries):
    result = {}
    for d in dictionaries:
        result.update(d)
    return result
