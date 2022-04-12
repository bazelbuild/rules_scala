# Adds testing.TestEnvironment provider if "env" attr is specified
# https://bazel.build/rules/lib/testing#TestEnvironment

def phase_test_environment(ctx, p):

    test_env = ctx.attr.env if "env" in dir(ctx.attr) else None

    if test_env:
        return struct(
          external_providers = {
            "TestingEnvironment": testing.TestEnvironment(test_env)
          }
        )

    return struct()