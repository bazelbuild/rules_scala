load(":providers.bzl", "JarsToLabels")

def _scala_import_impl(ctx):

    # Tread lightly when modifying this code! IntelliJ support needs
    # to be tested manually: manually [re-]import an intellij project
    # and ensure imports are resolved (not red) and clickable

    direct_binary_jars = []
    for jar in ctx.attr.jars:
        for file in jar.files:
            if not file.basename.endswith("-sources.jar"):
                direct_binary_jars += [file]


    s_deps = java_common.merge([
        entry[JavaInfo]
        for entry in ctx.attr.deps
        if JavaInfo in entry])

    s_exports = java_common.merge([
        entry[JavaInfo]
        for entry in ctx.attr.exports
        if JavaInfo in entry])

    s_runtime_deps = java_common.merge([
        entry[JavaInfo]
        for entry in ctx.attr.runtime_deps
        if JavaInfo in entry])


    compile_time_jars = depset(
        direct = direct_binary_jars,
        transitive = [
            s_exports.transitive_compile_time_jars])

    transitive_compile_time_jars = depset(
        transitive = [
            compile_time_jars,
            s_deps.transitive_compile_time_jars,
            s_exports.transitive_compile_time_jars])

    transitive_runtime_jars = depset(
        transitive = [
            compile_time_jars,
            s_deps.transitive_runtime_jars,
            s_exports.transitive_runtime_jars,
            s_runtime_deps.transitive_runtime_jars])


    lookup = {}
    for jar in direct_binary_jars:
        lookup[jar.path] = ctx.label

    for entry in ctx.attr.deps:
        if JavaInfo in entry:
            for jar in entry[JavaInfo].compile_jars:
                lookup[jar.path] = entry.label
        if JarsToLabels in entry:
            lookup.update(entry[JarsToLabels].lookup)

    for entry in ctx.attr.exports:
        if JavaInfo in entry:
            for jar in entry[JavaInfo].compile_jars:
                lookup[jar.path] = entry.label
        if JarsToLabels in entry:
            lookup.update(entry[JarsToLabels].lookup)

    return [
        JarsToLabels(lookup = lookup),
        java_common.create_provider(
            ctx.actions,
            use_ijar = False,
            compile_time_jars = compile_time_jars,
            transitive_compile_time_jars = transitive_compile_time_jars,
            transitive_runtime_jars = transitive_runtime_jars
        ),
    ]

scala_import = rule(
  implementation=_scala_import_impl,
  attrs={
      "jars": attr.label_list(allow_files=True), #current hidden assumption is that these point to full, not ijar'd jars
      "deps": attr.label_list(),
      "runtime_deps": attr.label_list(),
      "exports": attr.label_list()
      },
)
