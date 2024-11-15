load(
    "//scala:advanced_usage/providers.bzl",
    _ScalaRulePhase = "ScalaRulePhase",
)
load(
    "//scala/private:phases/phases.bzl",
    _phase_scalafmt = "phase_scalafmt",
)

ext_scalafmt = {
    "attrs": {
        "config": attr.label(
            allow_single_file = [".conf"],
            default = "@scalafmt_default//:config",
            doc = "The Scalafmt configuration file.",
        ),
        "format": attr.bool(
            default = False,
            doc = "Switch of enabling formatting.",
        ),
        "_fmt": attr.label(
            cfg = "exec",
            default = Label("//scala/scalafmt"),
            executable = True,
        ),
        "_java_host_runtime": attr.label(
            default = Label(
                "@rules_java//toolchains:current_host_java_runtime",
            ),
        ),
        "_runner": attr.label(
            allow_single_file = True,
            default = Label("//scala/scalafmt:runner"),
        ),
        "_testrunner": attr.label(
            allow_single_file = True,
            default = Label("//scala/scalafmt:testrunner"),
        ),
    },
    "outputs": {
        "scalafmt_runner": "%{name}.format",
        "scalafmt_testrunner": "%{name}.format-test",
    },
    "phase_providers": [
        Label("//scala/scalafmt:phase_scalafmt"),
    ],
}

def _scalafmt_singleton_implementation(ctx):
    return [
        _ScalaRulePhase(
            custom_phases = [
                # Placed before `runfiles` phase so the captured outputs and sources during creation of the
                # `TARGET.format-test` output script are made available as runfiles to other downstream
                # targets (for instance, a wrapping `sh_test` target which invokes that `TARGET.format-test`
                # script).  This allows them to by symlinked into the runfiles tree and thus accessible when
                # run via `bazel test`.
                ("-", "runfiles", "scalafmt", _phase_scalafmt),
            ],
        ),
    ]

scalafmt_singleton = rule(
    implementation = _scalafmt_singleton_implementation,
)
