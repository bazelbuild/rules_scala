load("@io_bazel_rules_scala//scala:providers.bzl", "DepsInfo")

def _required_provider_id_message(target, toolchain_type_label, provider_id):
    return target + " requires mapping of " + provider_id + " provider id on the toolchain " + toolchain_type_label

def java_info_for_deps(deps):
    return [java_common.merge([dep[JavaInfo] for dep in deps])]

def expose_toolchain_deps(ctx, toolchain_type_label):
    dep_provider_id = ctx.attr.provider_id
    dep_providers_map = getattr(ctx.toolchains[toolchain_type_label], "dep_providers")
    dep_provider = {v: k for k, v in dep_providers_map.items()}.get(dep_provider_id)

    if dep_provider == None:
        fail(_required_provider_id_message(ctx.attr.name, toolchain_type_label, dep_provider_id))

    deps = dep_provider[DepsInfo].deps
    return java_info_for_deps(deps)
