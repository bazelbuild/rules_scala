"""
This test makes sure that the implicit rule dependencies are discoverable by
an IDE. We stuff all dependencies into _scala_toolchain so we just need to make
sure the targets we expect are there.
"""
attr_aspects = ["_scala_toolchain", "deps"]

def _aspect_impl(target, ctx):
    visited = [str(target.label)]
    for attr_name in attr_aspects:
        if hasattr(ctx.rule.attr, attr_name):
            for dep in getattr(ctx.rule.attr, attr_name):
                if hasattr(dep, "visited"):
                    visited += dep.visited
    return struct(visited = visited)

test_aspect = aspect(
    attr_aspects = attr_aspects,
    implementation = _aspect_impl,
)

def _rule_impl(ctx):
    expected_deps = {
        "scala_library": [
            "//test/aspect:scala_library",
            "//scala/private/toolchain_deps:scala_library_classpath",
        ],
        "scala_test": [
            "//test/aspect:scala_test",
            "//scala/private/toolchain_deps:scala_library_classpath",
            "//testing/toolchain:scalatest_classpath",
        ],
        "scala_junit_test": [
            "//test/aspect:scala_junit_test",
            "//scala/private/toolchain_deps:scala_library_classpath",
            "//testing/toolchain:junit_classpath",
        ],
        "scala_specs2_junit_test": [
            "//scala/private/toolchain_deps:scala_library_classpath",
            "//test/aspect:scala_specs2_junit_test",
            "//testing/toolchain:junit_classpath",
            # From specs2/specs2.bzl:specs2_dependencies()
            "//specs2:specs2",
            "//scala/private/toolchain_deps:scala_xml",
            # From specs2/specs2_junit.bzl:specs2_junit_dependencies()
            "//testing/toolchain:specs2_junit_classpath",
        ],
    }
    content = ""
    for target in ctx.attr.targets:
        visited = depset(sorted(target.visited)).to_list()
        expected = depset(sorted(expected_deps[target.label.name])).to_list()
        if visited != expected:
            content += """
            echo Expected these deps from {name}: 1>&2
            echo {expected}, 1>&2
            echo but got these instead: 1>&2
            echo {visited} 1>&2
            false # test returns 1 (and fails) if this is the final line
            """.format(
                name = target.label.name,
                expected = ", ".join(expected),
                visited = ", ".join(visited),
            )
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = content,
    )
    return struct()

aspect_test = rule(
    implementation = _rule_impl,
    attrs = {
        # The targets whose dependencies we want to verify.
        "targets": attr.label_list(aspects = [test_aspect]),
    },
    test = True,
)
