load("//:scala_config.bzl", "scala_config")

def _scala_config_dep_impl(ctx):
    scala_config(enable_compiler_dependency_tracking = True)

scala_config_dep = module_extension(
    implementation = _scala_config_dep_impl,
)
