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
          "@io_bazel_rules_scala_scala_library//:io_bazel_rules_scala_scala_library",
      ],
      "scala_test": [
          "//test/aspect:scala_test",
          "@io_bazel_rules_scala_scala_library//:io_bazel_rules_scala_scala_library",
          "@io_bazel_rules_scala_scalatest//:io_bazel_rules_scala_scalatest",
      ],
      "scala_junit_test": [
          "//test/aspect:scala_junit_test",
          "@io_bazel_rules_scala_scala_library//:io_bazel_rules_scala_scala_library",
          "@io_bazel_rules_scala_junit_junit//jar:jar",
          "@io_bazel_rules_scala_org_hamcrest_hamcrest_core//jar:jar",
      ],
      "scala_specs2_junit_test": [
          "//test/aspect:scala_specs2_junit_test",
          "@io_bazel_rules_scala_scala_library//:io_bazel_rules_scala_scala_library",
          "@io_bazel_rules_scala_junit_junit//jar:jar",
          "@io_bazel_rules_scala_org_hamcrest_hamcrest_core//jar:jar",
          # From specs2/specs2.bzl:specs2_dependencies()
          "@io_bazel_rules_scala//specs2:specs2",
          "@io_bazel_rules_scala_scala_xml//:io_bazel_rules_scala_scala_xml",
          "@io_bazel_rules_scala_scala_parser_combinators//:io_bazel_rules_scala_scala_parser_combinators",
          "@io_bazel_rules_scala_scala_library//:io_bazel_rules_scala_scala_library",
          "@io_bazel_rules_scala_scala_reflect//:io_bazel_rules_scala_scala_reflect",
          # From specs2/specs2_junit.bzl:specs2_junit_dependencies()
          "@io_bazel_rules_scala_org_specs2_specs2_junit_2_11//jar:jar",
      ],
  }
  content = ""
  for target in ctx.attr.targets:
    visited = sorted(target.visited)
    expected = sorted(expected_deps[target.label.name])
    if visited != expected:
      content += """
            echo Expected these deps from {name}: 1>&2
            echo {expected}, 1>&2
            echo but got these instead: 1>&2
            echo {visited} 1>&2
            false # test returns 1 (and fails) if this is the final line
            """.format(
          name = target.label.name,
          expected = ', '.join(expected),
          visited = ', '.join(visited))
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
