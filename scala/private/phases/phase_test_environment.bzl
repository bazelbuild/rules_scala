# Adds testing.TestEnvironment provider if "env" attr is specified
# https://bazel.build/rules/lib/testing#TestEnvironment

def phase_test_environment(ctx, p):
    test_env = ctx.attr.env
    inherited_environment = ctx.attr.env_inherit

    if inherited_environment and test_env:
        return struct(
            external_providers = {
                "TestingEnvironment": testing.TestEnvironment(
                    test_env,
                    inherited_environment,
                ),
            },
        )

    elif test_env:
        return struct(
            external_providers = {
                "TestingEnvironment": testing.TestEnvironment(
                    test_env,
                ),
            },
        )

    elif inherited_environment:
        return struct(
            external_providers = {
                "TestingEnvironment": testing.TestEnvironment(
                    {},
                    inherited_environment,
                ),
            },
        )

    else:
        return struct()
