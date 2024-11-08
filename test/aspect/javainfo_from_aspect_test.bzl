load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

_VisitedRulesInfo = provider()

def _aspect_with_javainfo_required_imp(target, ctx):

    visited = dict([(target.label.name, "")])
    for dep in ctx.rule.attr.deps:
        visited.update(dep[_VisitedRulesInfo].visited)        
    
    return [
        _VisitedRulesInfo(visited = visited)
    ]

#An aspect that has "required_providers = [JavaInfo]."
#This is used to test that an aspect that has required_providers can access the JavaInfo provided by the scala_xxx targets
_aspect_with_javainfo_required = aspect(
    attr_aspects = ["deps"],
    required_providers = [JavaInfo],
    implementation = _aspect_with_javainfo_required_imp,
)


def _javainfo_from_aspect_test_imp(ctx):
    testenv = analysistest.begin(ctx)

    for expected in ctx.attr.expected:
        if(expected not in ctx.attr.target[_VisitedRulesInfo].visited):
            analysistest.fail(testenv, "Aspect did not visit expected target %s"%ctx.attr.expected)
    return analysistest.end(testenv)


javainfo_from_aspect_test = analysistest.make(
    impl = _javainfo_from_aspect_test_imp,
    attrs = {
        "target": attr.label(aspects = [_aspect_with_javainfo_required]),
        "expected": attr.string_list(), #The targets we expect to be visited by the aspect
    }        
)
