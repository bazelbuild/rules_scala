# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Rules for supporting the Scala language."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    ":common.bzl",
    _collect_plugin_paths = "collect_plugin_paths",
)
load(":resources.bzl", _resource_paths = "paths")

def expand_location(ctx, flags):
    if hasattr(ctx.attr, "data"):
        data = ctx.attr.data
    else:
        data = []
    return [ctx.expand_location(f, data) for f in flags]

def _join_path(args, sep = ","):
    return sep.join([f.path for f in args])

# Return the first non-empty arg. If all are empty, return the last.
def first_non_empty(*args):
    for arg in args:
        if arg:
            return arg
    return args[-1]

def compile_scala(
        ctx,
        target_label,
        output,
        manifest,
        statsfile,
        sources,
        cjars,
        all_srcjars,
        transitive_compile_jars,
        plugins,
        resource_strip_prefix,
        resources,
        resource_jars,
        labels,
        in_scalacopts,
        print_compile_time,
        expect_java_output,
        scalac_jvm_flags,
        scalac,
        dependency_info,
        unused_dependency_checker_ignored_targets):
    # look for any plugins:
    input_plugins = plugins
    plugins = _collect_plugin_paths(plugins)
    internal_plugin_jars = []
    compiler_classpath_jars = cjars
    if dependency_info.dependency_mode != "direct":
        compiler_classpath_jars = transitive_compile_jars
    optional_scalac_args = ""
    classpath_resources = []
    if (hasattr(ctx.files, "classpath_resources")):
        classpath_resources = ctx.files.classpath_resources

    optional_scalac_args_map = {}

    if dependency_info.use_analyzer:
        dep_plugin = ctx.attr._dependency_analyzer_plugin
        plugins = depset(transitive = [plugins, dep_plugin.files])
        internal_plugin_jars = ctx.files._dependency_analyzer_plugin

        current_target = str(target_label)
        optional_scalac_args_map["CurrentTarget"] = current_target

    if dependency_info.need_indirect_info:
        transitive_cjars_list = transitive_compile_jars.to_list()
        indirect_jars = _join_path(transitive_cjars_list)
        indirect_targets = ",".join([str(labels[j.path]) for j in transitive_cjars_list])

        optional_scalac_args_map["IndirectJars"] = indirect_jars
        optional_scalac_args_map["IndirectTargets"] = indirect_targets

    if dependency_info.unused_deps_mode != "off":
        ignored_targets = ",".join([str(d) for d in unused_dependency_checker_ignored_targets])
        optional_scalac_args_map["UnusedDepsIgnoredTargets"] = ignored_targets

    if dependency_info.need_direct_info:
        cjars_list = cjars.to_list()
        if dependency_info.need_direct_jars:
            direct_jars = _join_path(cjars_list)
            optional_scalac_args_map["DirectJars"] = direct_jars
        if dependency_info.need_direct_targets:
            direct_targets = ",".join([str(labels[j.path]) for j in cjars_list])
            optional_scalac_args_map["DirectTargets"] = direct_targets

    optional_scalac_args = "\n".join([
        "{k}: {v}".format(k = k, v = v)
        # We sort the arguments for input stability and reproducibility
        for (k, v) in sorted(optional_scalac_args_map.items())
    ])

    plugins_list = plugins.to_list()
    plugin_arg = _join_path(plugins_list)

    separator = ctx.configuration.host_path_separator
    compiler_classpath = _join_path(compiler_classpath_jars.to_list(), separator)

    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]
    scalacopts = [ctx.expand_location(v, input_plugins) for v in toolchain.scalacopts + in_scalacopts]
    resource_paths = _resource_paths(resources, resource_strip_prefix)

    scalac_args = """
Classpath: {cp}
ClasspathResourceSrcs: {classpath_resource_src}
Files: {files}
JarOutput: {out}
Manifest: {manifest}
Plugins: {plugin_arg}
PrintCompileTime: {print_compile_time}
ExpectJavaOutput: {expect_java_output}
ResourceTargets: {resource_targets}
ResourceSources: {resource_sources}
ResourceJars: {resource_jars}
ScalacOpts: {scala_opts}
SourceJars: {srcjars}
StrictDepsMode: {strict_deps_mode}
UnusedDependencyCheckerMode: {unused_dependency_checker_mode}
DependencyTrackingMethod: {dependency_tracking_method}
StatsfileOutput: {statsfile_output}
""".format(
        out = output.path,
        manifest = manifest.path,
        scala_opts = ",".join(scalacopts),
        print_compile_time = print_compile_time,
        expect_java_output = expect_java_output,
        plugin_arg = plugin_arg,
        cp = compiler_classpath,
        classpath_resource_src = _join_path(classpath_resources),
        files = _join_path(sources),
        srcjars = _join_path(all_srcjars.to_list()),
        # the resource paths need to be aligned in order
        resource_targets = ",".join([p[0] for p in resource_paths]),
        resource_sources = ",".join([p[1] for p in resource_paths]),
        resource_jars = _join_path(resource_jars),
        strict_deps_mode = dependency_info.strict_deps_mode,
        unused_dependency_checker_mode = dependency_info.unused_deps_mode,
        dependency_tracking_method = dependency_info.dependency_tracking_method,
        statsfile_output = statsfile.path,
    )

    argfile = ctx.actions.declare_file(
        "%s_scalac_worker_input" % target_label.name,
        sibling = output,
    )

    ctx.actions.write(
        output = argfile,
        content = scalac_args + optional_scalac_args,
    )

    scalac_inputs, _, scalac_input_manifests = ctx.resolve_command(
        tools = [scalac],
    )

    outs = [output, statsfile]
    ins = (
        compiler_classpath_jars.to_list() + all_srcjars.to_list() + list(sources) +
        plugins_list + internal_plugin_jars + classpath_resources + resources +
        resource_jars + [manifest, argfile] + scalac_inputs
    )

    # scalac_jvm_flags passed in on the target override scalac_jvm_flags passed in on the
    # toolchain
    final_scalac_jvm_flags = first_non_empty(
        scalac_jvm_flags,
        ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].scalac_jvm_flags,
    )

    ctx.actions.run(
        inputs = ins,
        outputs = outs,
        executable = scalac.files_to_run.executable,
        input_manifests = scalac_input_manifests,
        mnemonic = "Scalac",
        progress_message = "scala %s" % target_label,
        execution_requirements = {"supports-workers": "1"},
        #  when we run with a worker, the `@argfile.path` is removed and passed
        #  line by line as arguments in the protobuf. In that case,
        #  the rest of the arguments are passed to the process that
        #  starts up and stays resident.

        # In either case (worker or not), they will be jvm flags which will
        # be correctly handled since the executable is a jvm app that will
        # consume the flags on startup.
        arguments = [
            "--jvm_flag=%s" % f
            for f in expand_location(ctx, final_scalac_jvm_flags)
        ] + ["@" + argfile.path],
    )

def runfiles_root(ctx):
    return "${TEST_SRCDIR}/%s" % ctx.workspace_name

def java_bin(ctx):
    java_path = str(ctx.attr._java_runtime[java_common.JavaRuntimeInfo].java_executable_runfiles_path)
    if paths.is_absolute(java_path):
        javabin = java_path
    else:
        runfiles_root_var = runfiles_root(ctx)
        javabin = "%s/%s" % (runfiles_root_var, java_path)
    return javabin

def is_windows(ctx):
    return ctx.configuration.host_path_separator == ";"
