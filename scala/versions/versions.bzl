def _scala_version_transition_impl(settings, attr):
    if attr.scala_version:
        return {"//scala/versions:scala_version": attr.scala_version}
    else:
        return {}

scala_version_transition = transition(
    implementation = _scala_version_transition_impl,
    inputs = [],
    outputs = ["//scala/versions:scala_version"],
)

toolchain_transition_attr = {
    "scala_version": attr.string(),
    "_allowlist_function_transition": attr.label(
        default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
    ),
}

def sanitize_version(scala_version):
    return scala_version.replace(".", "_")
