"""Rule for declaring a Service Provider in scala.
A service provider is like a scala library, except it also accepts
a `services` attribute which is used to load configurable services
using the `Service Provider Interface` as described here:
https://docs.oracle.com/javase/tutorial/ext/basics/spi.html
"""
load("@io_bazel_rules_scala//scala:advanced_usage/providers.bzl", "ScalaRulePhase")
load("@io_bazel_rules_scala//scala:advanced_usage/scala.bzl", "make_scala_library")


def _phase_write_services_files(ctx, p):
    resources = [resource for resource in ctx.files.resources]
    for service, impls in ctx.attr.services.items():
        service_file_path = ctx.actions.declare_file("META-INF/services/" + service)
        ctx.actions.write(
            output = service_file_path,
            content = "\n".join(impls)+ "\n"
        )
        resources.append(service_file_path)
    return resources

service_provider_custom_phase = {
    "attrs": {
        "services": attr.string_list_dict(),
    },
    "phase_providers": [
        "phase_write_services_files",
    ],
}

scala_service_provider = make_scala_library(service_provider_custom_phase)


def _scala_service_provider_singleton_implementation(ctx):
    return [
        ScalaRulePhase(
            custom_phases = [
                ("$", "", "phase_write_services_file", _phase_write_services_files),
            ],
        ),
    ]

scala_service_provider_singleton = rule(
    implementation = _scala_service_provider_singleton_implementation,
)
