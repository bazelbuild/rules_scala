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
load("@bazel_tools//tools/jdk:toolchain_utils.bzl", "find_java_runtime_toolchain", "find_java_toolchain")
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
        diagnosticsfile,
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

    args = ctx.actions.args()
    args.set_param_file_format("multiline")
    args.use_param_file(param_file_arg = "@%s", use_always = True)

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

    if dependency_info.use_analyzer:
        dep_plugin = ctx.attr._dependency_analyzer_plugin
        plugins = depset(transitive = [plugins, dep_plugin.files])
        internal_plugin_jars = ctx.files._dependency_analyzer_plugin

        current_target = str(target_label)
        args.add("--CurrentTarget", current_target)

    if dependency_info.need_indirect_info:
        transitive_cjars_list = transitive_compile_jars.to_list()
        indirect_jars = _join_path(transitive_cjars_list)
        indirect_targets = ",".join([str(labels[j.path]) for j in transitive_cjars_list])

        args.add_joined("--IndirectJars", transitive_compile_jars, join_with = ",", omit_if_empty = False)
        args.add("--IndirectTargets", indirect_targets)

    if dependency_info.unused_deps_mode != "off":
        ignored_targets = ",".join([str(d) for d in unused_dependency_checker_ignored_targets])
        args.add("--UnusedDepsIgnoredTargets", ignored_targets)

    if dependency_info.need_direct_info:
        cjars_list = cjars.to_list()
        if dependency_info.need_direct_jars:
            direct_jars = _join_path(cjars_list)
            args.add_joined("--DirectJars", cjars_list, join_with = ",", omit_if_empty = False)
        if dependency_info.need_direct_targets:
            direct_targets = ",".join([str(labels[j.path]) for j in cjars_list])
            args.add("--DirectTargets", direct_targets)

    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]
    scalacopts = [ctx.expand_location(v, input_plugins) for v in toolchain.scalacopts + in_scalacopts]
    resource_paths = _resource_paths(resources, resource_strip_prefix)
    enable_diagnostics_report = toolchain.enable_diagnostics_report

    args.add_joined("--Classpath", compiler_classpath_jars, join_with = ctx.configuration.host_path_separator, omit_if_empty = False)
    args.add_joined("--ClasspathResourceSrcs", classpath_resources, join_with = ",", omit_if_empty = False)
    args.add_joined("--Files", sources, join_with = ",", omit_if_empty = False)
    args.add("--JarOutput", output)
    args.add("--Manifest", manifest)
    args.add_joined("--Plugins", plugins, join_with = ",", omit_if_empty = False)
    args.add("--PrintCompileTime", print_compile_time)
    args.add("--ExpectJavaOutput", expect_java_output)
    args.add_joined("--ResourceTargets", [p[0] for p in resource_paths], join_with = ",", omit_if_empty = False)
    args.add_joined("--ResourceSources", [p[1] for p in resource_paths], join_with = ",", omit_if_empty = False)
    args.add_joined("--ResourceJars", resource_jars, join_with = ",", omit_if_empty = False)
    args.add_joined("--ScalacOpts", scalacopts, join_with = ":::", omit_if_empty = False)
    args.add_joined("--SourceJars", all_srcjars, join_with = ",", omit_if_empty = False)
    args.add("--StrictDepsMode", dependency_info.strict_deps_mode)
    args.add("--UnusedDependencyCheckerMode", dependency_info.unused_deps_mode)
    args.add("--DependencyTrackingMethod", dependency_info.dependency_tracking_method)
    args.add("--StatsfileOutput", statsfile)
    args.add("--EnableDiagnosticsReport", enable_diagnostics_report)
    args.add("--DiagnosticsFile", diagnosticsfile)

    outs = [output, statsfile, diagnosticsfile]

    ins = depset(
        direct = [manifest] + sources + internal_plugin_jars + classpath_resources + resources + resource_jars + scalac_inputs,
        transitive = [compiler_classpath_jars, all_srcjars, plugins]
    )

    # scalac_jvm_flags passed in on the target override scalac_jvm_flags passed in on the
    # toolchain
    final_scalac_jvm_flags = first_non_empty(
        scalac_jvm_flags,
        ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].scalac_jvm_flags,
    )
    if len(BAZEL_VERSION) == 0 and enable_diagnostics_report:  # TODO: Add case for released version of bazel with diagnostics whenever it is released.
        ctx.actions.run(
            inputs = ins,
            outputs = outs,
            executable = scalac,
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
            ] + [args],
            diagnostics_file = diagnosticsfile,
        )
    else:
        ctx.actions.run(
            inputs = ins,
            outputs = outs,
            executable = scalac,
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
            ] + [args],
        )

def compile_java(ctx, source_jars, source_files, output, extra_javac_opts, providers_of_dependencies):
    return java_common.compile(
        ctx,
        source_jars = source_jars,
        source_files = source_files,
        output = output,
        javac_opts = expand_location(
            ctx,
            extra_javac_opts +
            java_common.default_javac_opts(
                java_toolchain = ctx.attr._java_toolchain[java_common.JavaToolchainInfo],
            ),
        ),
        deps = providers_of_dependencies,
        #exports can be empty since the manually created provider exposes exports
        #needs to be empty since we want the provider.compile_jars to only contain the sources ijar
        #workaround until https://github.com/bazelbuild/bazel/issues/3528 is resolved
        exports = [],
        neverlink = getattr(ctx.attr, "neverlink", False),
        java_toolchain = find_java_toolchain(ctx, ctx.attr._java_toolchain),
        host_javabase = find_java_runtime_toolchain(ctx, ctx.attr._host_javabase),
        strict_deps = ctx.fragments.java.strict_java_deps,
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
