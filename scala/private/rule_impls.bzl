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

load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _ScalacProvider = "ScalacProvider",
)
load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)
load(
    ":common.bzl",
    _collect_jars = "collect_jars",
    _collect_plugin_paths = "collect_plugin_paths",
)

def adjust_resources_path_by_default_prefixes(path):
    #  Here we are looking to find out the offset of this resource inside
    #  any resources folder. We want to return the root to the resources folder
    #  and then the sub path inside it
    dir_1, dir_2, rel_path = path.partition("resources")
    if rel_path:
        return dir_1 + dir_2, rel_path

    #  The same as the above but just looking for java
    (dir_1, dir_2, rel_path) = path.partition("java")
    if rel_path:
        return dir_1 + dir_2, rel_path

    return "", path

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
        unused_dependency_checker_mode = "off",
        unused_dependency_checker_ignored_targets = []):
    # look for any plugins:
    input_plugins = plugins
    plugins = _collect_plugin_paths(plugins)
    internal_plugin_jars = []
    dependency_analyzer_mode = "off"
    compiler_classpath_jars = cjars
    optional_scalac_args = ""
    classpath_resources = []
    if (hasattr(ctx.files, "classpath_resources")):
        classpath_resources = ctx.files.classpath_resources

    if is_dependency_analyzer_on(ctx):
        # "off" mode is used as a feature toggle, that preserves original behaviour
        dependency_analyzer_mode = ctx.fragments.java.strict_java_deps
        dep_plugin = ctx.attr._dependency_analyzer_plugin
        plugins = depset(transitive = [plugins, dep_plugin.files])
        internal_plugin_jars = ctx.files._dependency_analyzer_plugin
        compiler_classpath_jars = transitive_compile_jars

        direct_jars = _join_path(cjars.to_list())

        transitive_cjars_list = transitive_compile_jars.to_list()
        indirect_jars = _join_path(transitive_cjars_list)
        indirect_targets = ",".join([str(labels[j.path]) for j in transitive_cjars_list])

        current_target = str(target_label)

        optional_scalac_args = """
DirectJars: {direct_jars}
IndirectJars: {indirect_jars}
IndirectTargets: {indirect_targets}
CurrentTarget: {current_target}
        """.format(
            direct_jars = direct_jars,
            indirect_jars = indirect_jars,
            indirect_targets = indirect_targets,
            current_target = current_target,
        )

    elif unused_dependency_checker_mode != "off":
        unused_dependency_plugin = ctx.attr._unused_dependency_checker_plugin
        plugins = depset(transitive = [plugins, unused_dependency_plugin.files])
        internal_plugin_jars = ctx.files._unused_dependency_checker_plugin

        cjars_list = cjars.to_list()
        direct_jars = _join_path(cjars_list)
        direct_targets = ",".join([str(labels[j.path]) for j in cjars_list])

        ignored_targets = ",".join([str(d) for d in unused_dependency_checker_ignored_targets])

        current_target = str(target_label)

        optional_scalac_args = """
DirectJars: {direct_jars}
DirectTargets: {direct_targets}
IgnoredTargets: {ignored_targets}
CurrentTarget: {current_target}
        """.format(
            direct_jars = direct_jars,
            direct_targets = direct_targets,
            ignored_targets = ignored_targets,
            current_target = current_target,
        )
    if is_dependency_analyzer_off(ctx) and not _is_plus_one_deps_off(ctx):
        compiler_classpath_jars = transitive_compile_jars

    plugins_list = plugins.to_list()
    plugin_arg = _join_path(plugins_list)

    separator = ctx.configuration.host_path_separator
    compiler_classpath = _join_path(compiler_classpath_jars.to_list(), separator)

    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]
    scalacopts = [ctx.expand_location(v, input_plugins) for v in toolchain.scalacopts + in_scalacopts]

    scalac_args = """
Classpath: {cp}
ClasspathResourceSrcs: {classpath_resource_src}
Files: {files}
JarOutput: {out}
Manifest: {manifest}
Plugins: {plugin_arg}
PrintCompileTime: {print_compile_time}
ExpectJavaOutput: {expect_java_output}
ResourceDests: {resource_dest}
ResourceJars: {resource_jars}
ResourceSrcs: {resource_src}
ResourceShortPaths: {resource_short_paths}
ResourceStripPrefix: {resource_strip_prefix}
ScalacOpts: {scala_opts}
SourceJars: {srcjars}
DependencyAnalyzerMode: {dependency_analyzer_mode}
UnusedDependencyCheckerMode: {unused_dependency_checker_mode}
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
        resource_src = ",".join([f.path for f in resources]),
        resource_short_paths = ",".join([f.short_path for f in resources]),
        resource_dest = ",".join([
            adjust_resources_path_by_default_prefixes(f.short_path)[1]
            for f in resources
        ]),
        resource_strip_prefix = resource_strip_prefix,
        resource_jars = _join_path(resource_jars),
        dependency_analyzer_mode = dependency_analyzer_mode,
        unused_dependency_checker_mode = unused_dependency_checker_mode,
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

def get_scalac_provider(ctx):
    return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].scalac_provider_attr[_ScalacProvider]

def merge_jars(actions, deploy_jar, singlejar_executable, jars_list, main_class = "", progress_message = ""):
    """Calls Bazel's singlejar utility.

    For a full list of available command line options see:
    https://github.com/bazelbuild/bazel/blob/697d219526bffbecd29f29b402c9122ec5d9f2ee/src/java_tools/singlejar/java/com/google/devtools/build/singlejar/SingleJar.java#L337
    Use --compression to reduce size of deploy jars.

    Args:
        actions: The actions module from ctx: https://docs.bazel.build/versions/master/skylark/lib/actions.html
        deploy_jar: The deploy jar, usually defined in ctx.outputs.
        singlejar_executable: The singlejar executable file.
        jars_list: The jars to pass to singlejar.
        main_class: The main class to run, if any. Defaults to an empty string.
        progress_message: A progress message to display when Bazel executes this action. Defaults to an empty string.
    """
    args = ["--compression", "--normalize", "--sources"]
    args.extend([j.path for j in jars_list])
    if main_class:
        args.extend(["--main_class", main_class])
    args.extend(["--output", deploy_jar.path])
    actions.run(
        inputs = jars_list,
        outputs = [deploy_jar],
        executable = singlejar_executable,
        mnemonic = "ScalaDeployJar",
        progress_message = progress_message,
        arguments = args,
    )

def _path_is_absolute(path):
    # Returns true for absolute path in Linux/Mac (i.e., '/') or Windows (i.e.,
    # 'X:\' or 'X:/' where 'X' is a letter), false otherwise.
    if len(path) >= 1 and path[0] == "/":
        return True
    if len(path) >= 3 and \
       path[0].isalpha() and \
       path[1] == ":" and \
       (path[2] == "/" or path[2] == "\\"):
        return True

    return False

def _runfiles_root(ctx):
    return "${TEST_SRCDIR}/%s" % ctx.workspace_name

def _java_bin(ctx):
    java_path = str(ctx.attr._java_runtime[java_common.JavaRuntimeInfo].java_executable_runfiles_path)
    if _path_is_absolute(java_path):
        javabin = java_path
    else:
        runfiles_root = _runfiles_root(ctx)
        javabin = "%s/%s" % (runfiles_root, java_path)
    return javabin

def write_java_wrapper(ctx, args = "", wrapper_preamble = ""):
    """This creates a wrapper that sets up the correct path
         to stand in for the java command."""

    exec_str = ""
    if wrapper_preamble == "":
        exec_str = "exec "

    wrapper = ctx.actions.declare_file(ctx.label.name + "_wrapper.sh")
    ctx.actions.write(
        output = wrapper,
        content = """#!/usr/bin/env bash
{preamble}
DEFAULT_JAVABIN={javabin}
JAVA_EXEC_TO_USE=${{REAL_EXTERNAL_JAVA_BIN:-$DEFAULT_JAVABIN}}
{exec_str}$JAVA_EXEC_TO_USE "$@" {args}
""".format(
            preamble = wrapper_preamble,
            exec_str = exec_str,
            javabin = _java_bin(ctx),
            args = args,
        ),
        is_executable = True,
    )
    return wrapper

def _jar_path_based_on_java_bin(ctx):
    java_bin = _java_bin(ctx)
    jar_path = java_bin.rpartition("/")[0] + "/jar"
    return jar_path

def write_executable(ctx, executable, rjars, main_class, jvm_flags, wrapper, use_jacoco):
    if (is_windows(ctx)):
        return write_executable_windows(ctx, executable, rjars, main_class, jvm_flags, wrapper, use_jacoco)
    else:
        return write_executable_non_windows(ctx, executable, rjars, main_class, jvm_flags, wrapper, use_jacoco)

def write_executable_windows(ctx, executable, rjars, main_class, jvm_flags, wrapper, use_jacoco):
    # NOTE: `use_jacoco` is currently ignored on Windows.
    # TODO: tests coverage support for Windows
    classpath = ";".join(
        [("external/%s" % (j.short_path[3:]) if j.short_path.startswith("../") else j.short_path) for j in rjars.to_list()],
    )
    jvm_flags_str = ";".join(jvm_flags)
    java_for_exe = str(ctx.attr._java_runtime[java_common.JavaRuntimeInfo].java_executable_exec_path)

    cpfile = ctx.actions.declare_file("%s.classpath" % ctx.label.name)
    ctx.actions.write(cpfile, classpath)

    ctx.actions.run(
        outputs = [executable],
        inputs = [cpfile],
        executable = ctx.attr._exe.files_to_run.executable,
        arguments = [executable.path, ctx.workspace_name, java_for_exe, main_class, cpfile.path, jvm_flags_str],
        mnemonic = "ExeLauncher",
        progress_message = "Creating exe launcher",
    )
    return []

def write_executable_non_windows(ctx, executable, rjars, main_class, jvm_flags, wrapper, use_jacoco):
    template = ctx.attr._java_stub_template.files.to_list()[0]

    jvm_flags = " ".join(
        [ctx.expand_location(f, ctx.attr.data) for f in jvm_flags],
    )

    javabin = "export REAL_EXTERNAL_JAVA_BIN=${JAVABIN};JAVABIN=%s/%s" % (
        _runfiles_root(ctx),
        wrapper.short_path,
    )

    if use_jacoco and _coverage_replacements_provider.is_enabled(ctx):
        classpath = ctx.configuration.host_path_separator.join(
            ["${RUNPATH}%s" % (j.short_path) for j in rjars.to_list() + ctx.files._jacocorunner],
        )
        jacoco_metadata_file = ctx.actions.declare_file(
            "%s.jacoco_metadata.txt" % ctx.attr.name,
            sibling = executable,
        )
        ctx.actions.write(jacoco_metadata_file, "\n".join([
            jar.short_path.replace("../", "external/")
            for jar in rjars.to_list()
        ]))
        ctx.actions.expand_template(
            template = template,
            output = executable,
            substitutions = {
                "%classpath%": "\"%s\"" % classpath,
                "%javabin%": javabin,
                "%jarbin%": _jar_path_based_on_java_bin(ctx),
                "%jvm_flags%": jvm_flags,
                "%needs_runfiles%": "",
                "%runfiles_manifest_only%": "",
                "%workspace_prefix%": ctx.workspace_name + "/",
                "%java_start_class%": "com.google.testing.coverage.JacocoCoverageRunner",
                "%set_jacoco_metadata%": "export JACOCO_METADATA_JAR=\"$JAVA_RUNFILES/{}/{}\"".format(ctx.workspace_name, jacoco_metadata_file.short_path),
                "%set_jacoco_main_class%": """export JACOCO_MAIN_CLASS={}""".format(main_class),
                "%set_jacoco_java_runfiles_root%": """export JACOCO_JAVA_RUNFILES_ROOT=$JAVA_RUNFILES/{}/""".format(ctx.workspace_name),
                "%set_java_coverage_new_implementation%": """export JAVA_COVERAGE_NEW_IMPLEMENTATION=YES""",
            },
            is_executable = True,
        )
        return [jacoco_metadata_file]
    else:
        # RUNPATH is defined here:
        # https://github.com/bazelbuild/bazel/blob/0.4.5/src/main/java/com/google/devtools/build/lib/bazel/rules/java/java_stub_template.txt#L227
        classpath = ctx.configuration.host_path_separator.join(
            ["${RUNPATH}%s" % (j.short_path) for j in rjars.to_list()],
        )
        ctx.actions.expand_template(
            template = template,
            output = executable,
            substitutions = {
                "%classpath%": "\"%s\"" % classpath,
                "%java_start_class%": main_class,
                "%javabin%": javabin,
                "%jarbin%": _jar_path_based_on_java_bin(ctx),
                "%jvm_flags%": jvm_flags,
                "%needs_runfiles%": "",
                "%runfiles_manifest_only%": "",
                "%set_jacoco_metadata%": "",
                "%set_jacoco_main_class%": "",
                "%set_jacoco_java_runfiles_root%": "",
                "%workspace_prefix%": ctx.workspace_name + "/",
                "%set_java_coverage_new_implementation%": """export JAVA_COVERAGE_NEW_IMPLEMENTATION=NO""",
            },
            is_executable = True,
        )
        return []

def _collect_runtime_jars(dep_targets):
    runtime_jars = []

    for dep_target in dep_targets:
        runtime_jars.append(dep_target[JavaInfo].transitive_runtime_jars)

    return runtime_jars

def is_dependency_analyzer_on(ctx):
    if (hasattr(ctx.attr, "_dependency_analyzer_plugin") and
        # when the strict deps FT is removed the "default" check
        # will be removed since "default" will mean it's turned on
        ctx.fragments.java.strict_java_deps != "default" and
        ctx.fragments.java.strict_java_deps != "off"):
        return True

def is_dependency_analyzer_off(ctx):
    return not is_dependency_analyzer_on(ctx)

def _is_plus_one_deps_off(ctx):
    return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].plus_one_deps_mode == "off"

# Extract very common code out from dependency analysis into single place
# automatically adds dependency on scala-library and scala-reflect
# collects jars from deps, runtime jars from runtime_deps, and
def collect_jars_from_common_ctx(
        ctx,
        base_classpath,
        extra_deps = [],
        extra_runtime_deps = [],
        unused_dependency_checker_is_off = True):
    dependency_analyzer_is_off = is_dependency_analyzer_off(ctx)

    deps_jars = _collect_jars(
        ctx.attr.deps + extra_deps + base_classpath,
        dependency_analyzer_is_off,
        unused_dependency_checker_is_off,
        _is_plus_one_deps_off(ctx),
    )

    (
        cjars,
        transitive_rjars,
        jars2labels,
        transitive_compile_jars,
        deps_providers,
    ) = (
        deps_jars.compile_jars,
        deps_jars.transitive_runtime_jars,
        deps_jars.jars2labels,
        deps_jars.transitive_compile_jars,
        deps_jars.deps_providers,
    )

    transitive_rjars = depset(
        transitive = [transitive_rjars] +
                     _collect_runtime_jars(ctx.attr.runtime_deps + extra_runtime_deps),
    )

    return struct(
        compile_jars = cjars,
        jars2labels = jars2labels,
        transitive_compile_jars = transitive_compile_jars,
        transitive_runtime_jars = transitive_rjars,
        deps_providers = deps_providers,
    )

def get_unused_dependency_checker_mode(ctx):
    if ctx.attr.unused_dependency_checker_mode:
        return ctx.attr.unused_dependency_checker_mode
    else:
        return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].unused_dependency_checker_mode

def is_windows(ctx):
    return ctx.configuration.host_path_separator == ";"
