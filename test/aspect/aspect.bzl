attr_aspects = [
    "deps",
    "runtime_deps",
    "_scalalib",
    "_scalareflect",
    "_scalatest_reporter",
]

def _aspect_impl(target, ctx):
    visited = [target.label.name]
    for name in attr_aspects:
        if hasattr(ctx.rule.attr, name):
            attr = getattr(ctx.rule.attr, name)
            # Need to handle whether attribute is label or label list
            children = attr if type(attr) == "list" else [attr]
            for child in children:
                if hasattr(child, "visited"):
                    visited += child.visited
    return struct(visited = visited)

test_aspect = aspect(
    attr_aspects = attr_aspects,
    implementation = _aspect_impl,
)

def _rule_impl(ctx):
    expected = [
        "dummy",
        "jar", # This is scalatest since @scalatest/jar
        "scala-library",
        "scala-reflect",
        "scala-xml", # dependency of test_reporter
        "test_reporter",
    ]
    # Remove duplicates and sort so can do simple comparison
    visited = sorted(depset(ctx.attr.scala_rule.visited).to_list())
    if visited == expected:
        content = "true"
    else:
        content = """
        echo Expected these rules to be visited by the aspect: 1>&2
        echo %s, 1>&2
        echo but got these instead: 1>&2
        echo %s 1>&2
        false
        """ % (', '.join(expected), ', '.join(visited))
    ctx.file_action(
        output = ctx.outputs.executable,
        content = content,
    )
    return struct()

aspect_test = rule(
    implementation = _rule_impl,
    attrs = { "scala_rule" : attr.label(aspects = [test_aspect]) },
    test = True,
)

