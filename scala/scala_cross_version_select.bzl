load("@rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load(":scala_cross_version.bzl", "version_suffix")

def select_for_scala_version(default = [], **kwargs):
    """
    User-friendly macro replacement for select() conditioned on Scala versions.

    Example usage:
    ```
    srcs = select_for_scala_version(
        before_3_1 = [
            # for Scala version < 3.1
        ],
        between_3_1_and_3_2 = [
            # for 3.1 ≤ Scala version < 3.2
        ],
        between_3_2_and_3_3_1 = [
            # for 3.2 ≤ Scala version < 3.3.1
        ],
        since_3_3_1 = [
            # for 3.3.1 ≤ Scala version
        ],
    )
    ```

    This function parses the provided keyword argument names.
    Each argument name starts with the matcher name and is followed by matcher argument (the version to compare against).
    All versions must have their "." replaced with "_".

    Available matchers:
    * `before`, `after` – that will match any version strictly lower / strictly greater than provided;
    * `until`, `since` – that will match any version lower or equal / greater or equal than provided;
    * `any` – that will match any version equal to provided;
    * `between` – requires two versions separated by `_and_`, combines `since` and `before`.

    If only a part of a version, e.g. "2.13", is provided, the remaining part will be ignored during comparison.
    Therefore "any_2" is interpreted as a wildcard "2.*.*".

    Unlike the traditional `select()`, all matches will be respected.
    `default` is applied for versions not matched by any matcher.
    """

    return select({
        "@rules_scala_config//:scala_version" + version_suffix(scala_version): _matches_for_version(scala_version, kwargs, default)
        for scala_version in SCALA_VERSIONS
    })

def _matches_for_version(scala_version, kwargs, default_value):
    matches = []
    default = True
    for matcher, value in kwargs.items():
        matcher_name, matcher_args = matcher.split("_", 1)
        matcher_args = matcher_args.split("_and_")
        if _MATCHERS[matcher_name](scala_version, *matcher_args):
            matches.extend(value)
            default = False
    if default:
        matches.extend(default_value)
    return matches

def _match_one_arg(scala_version, matcher_scala_version, compare):
    # Some rudimentary version parsing to allow a lexicographical compare later.
    # Works for versions containing numbers only.
    scala_version = tuple([int(x) for x in scala_version.split(".")])
    matcher_scala_version = tuple([int(x) for x in matcher_scala_version.split("_")])

    # Compare only a part of version – to allow wildcarding.
    return compare(scala_version[:len(matcher_scala_version)], matcher_scala_version)

def _build_matcher(compare):
    def matcher(scala_version, matcher_scala_version):
        return _match_one_arg(scala_version, matcher_scala_version, compare)

    return matcher

_match_any = _build_matcher(lambda x, y: x == y)
_match_before = _build_matcher(lambda x, y: x < y)
_match_after = _build_matcher(lambda x, y: x > y)
_match_until = _build_matcher(lambda x, y: x <= y)
_match_since = _build_matcher(lambda x, y: x >= y)

def _match_between(scala_version, since_scala_version, until_scala_version):
    return _match_since(scala_version, since_scala_version) and \
           _match_before(scala_version, until_scala_version)

_MATCHERS = {
    # Exclusive matchers:
    "before": _match_before,
    "after": _match_after,

    # Inclusive matchers:
    "any": _match_any,
    "until": _match_until,
    "since": _match_since,

    # Mixed matchers:
    "between": _match_between,  # (inclusive-exclusive)
}
