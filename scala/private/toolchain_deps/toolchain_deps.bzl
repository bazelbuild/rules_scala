load("@io_bazel_rules_scala//scala:providers.bzl", "DepsInfo")

def _required_depset_id_message(target, toolchain_type_label, depset_id):
    return target + " requires mapping of " + depset_id + " provider id on the toolchain " + toolchain_type_label

def java_info_for_deps(deps):
    return [java_common.merge([dep[JavaInfo] for dep in deps])]

def _lookup_provider_by_id(ctx, toolchain_type_label, dep_providers, depset_id):
    for dep_provider in dep_providers:
        if dep_provider[DepsInfo].depset_id == depset_id:
            return dep_provider
    fail(_required_depset_id_message(ctx.attr.name, toolchain_type_label, depset_id))

def find_deps_info_on(ctx, toolchain_type_label, depset_id):
    dep_providers = getattr(ctx.toolchains[toolchain_type_label], "dep_providers")

    return _lookup_provider_by_id(ctx, toolchain_type_label, dep_providers, depset_id)[DepsInfo]

def expose_toolchain_deps(ctx, toolchain_type_label):
    depset_id = ctx.attr.depset_id
    deps_info = find_deps_info_on(ctx, toolchain_type_label, depset_id)
    return java_info_for_deps(deps_info.deps)
