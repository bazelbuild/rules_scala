load("//scala:providers.bzl", _ScalacProvider = "ScalacProvider")

#
# PHASE: scalac provider
#
# DOCUMENT THIS
#
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "find_deps_info_on")

def phase_scalac_provider(ctx, p):
    toolchain_type_label = "//scala:toolchain_type"

    library_classpath = find_deps_info_on(ctx, toolchain_type_label, "scala_library_classpath").deps
    compile_classpath = find_deps_info_on(ctx, toolchain_type_label, "scala_compile_classpath").deps
    macro_classpath = find_deps_info_on(ctx, toolchain_type_label, "scala_macro_classpath").deps

    return _ScalacProvider(
        default_classpath = library_classpath,
        default_repl_classpath = compile_classpath,
        default_macro_classpath = macro_classpath,
    )
