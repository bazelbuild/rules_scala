def _files_of(deps):
    files = []
    for dep in deps:
        files.append(dep[JavaInfo].transitive_compile_time_jars)
    return depset(transitive = files)

def _export_scalac_repositories_from_toolchain_to_jvm_impl(ctx):
    default_repl_classpath_deps = ctx.toolchains["@io_bazel_rules_scala//scala:bootstrap_toolchain_type"].bootstrapinfo.repl_classpath
    default_repl_classpath_files = _files_of(
        default_repl_classpath_deps,
    ).to_list()
    providers = [JavaInfo(output_jar = jar, compile_jar = jar) for jar in default_repl_classpath_files]
    return [java_common.merge(providers)]

export_scalac_repositories_from_toolchain_to_jvm = rule(
    _export_scalac_repositories_from_toolchain_to_jvm_impl,
    toolchains = ["@io_bazel_rules_scala//scala:bootstrap_toolchain_type"],
)
