load("@rules_java//java/common:java_common.bzl", "java_common")
load("@rules_java//java/common:java_info.bzl", "JavaInfo")
load("//scala:providers.bzl", "DepsInfo")

def _required_deps_id_message(target, toolchain_type_label, deps_id):
    return target + " requires mapping of " + deps_id + " provider id on the toolchain " + toolchain_type_label

def java_info_for_deps(deps):
    return [java_common.merge([dep[JavaInfo] for dep in deps])]

def _lookup_provider_by_id(ctx, toolchain_type_label, dep_providers, deps_id):
    for dep_provider in dep_providers:
        if dep_provider[DepsInfo].deps_id == deps_id:
            return dep_provider
    fail(_required_deps_id_message(ctx.attr.name, toolchain_type_label, deps_id))

def find_deps_info_on(ctx, toolchain_type_label, deps_id):
    dep_providers = getattr(ctx.toolchains[toolchain_type_label], "dep_providers")

    return _lookup_provider_by_id(ctx, toolchain_type_label, dep_providers, deps_id)[DepsInfo]

def expose_toolchain_deps(ctx, toolchain_type_label):
    deps_id = ctx.attr.deps_id
    deps_info = find_deps_info_on(ctx, toolchain_type_label, deps_id)
    return java_info_for_deps(deps_info.deps)
