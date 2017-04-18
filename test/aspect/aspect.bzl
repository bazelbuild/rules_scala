attr_aspects = [
    "_scalalib",
    "_scalacompiler",
    "_scalareflect",
    "_scalaxml",
]

def _aspect_impl(target, ctx):
    visited = [target.label.name]
    for name in attr_aspects:
        if hasattr(ctx.rule.attr, name):
            attr = getattr(ctx.rule.attr, name)
            if hasattr(attr, "visited"):
                visited += attr.visited
    return struct(visited = visited)

test_aspect = aspect(
    attr_aspects = attr_aspects,
    implementation = _aspect_impl,
)

def _rule_impl(ctx):
    expected = [
        "dummy",
        "scala-library",
        "scala-compiler",
        "scala-reflect",
        "scala-xml",
    ]
    visited = ctx.attr.scala_rule.visited
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

