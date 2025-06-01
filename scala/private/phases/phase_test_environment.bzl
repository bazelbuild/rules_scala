# Adds testing.TestEnvironment provider if "env" attr is specified
# https://bazel.build/rules/lib/testing#TestEnvironment

def phase_test_environment(ctx, p):
    return struct(
        external_providers = {
            "TestingEnvironment": testing.TestEnvironment(
                {k: ctx.expand_location(v, ctx.attr.data) for k, v in ctx.attr.env.items()},
                ctx.attr.env_inherit,
            ),
        },
    )
