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

load("//specs2:specs2_junit.bzl", "specs2_junit_dependencies")
load(":scala_cross_version.bzl", "scala_version", "scala_mvn_artifact")
load("@io_bazel_rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")
load(":providers.bzl", "JarsToLabels")

_jar_filetype = FileType([".jar"])
_java_filetype = FileType([".java"])
_scala_filetype = FileType([".scala"])
_srcjar_filetype = FileType([".srcjar"])
# TODO is there a way to derive this from the above?
_scala_srcjar_filetype = FileType([".scala", ".srcjar", ".java"])

def _adjust_resources_path_by_strip_prefix(path, resource_strip_prefix):
    if not path.startswith(resource_strip_prefix):
      fail("Resource file %s is not under the specified prefix to strip" % path)

    clean_path = path[len(resource_strip_prefix):]
    return resource_strip_prefix, clean_path

def _adjust_resources_path_by_default_prefixes(path):
      #  Here we are looking to find out the offset of this resource inside
      #  any resources folder. We want to return the root to the resources folder
      #  and then the sub path inside it
      dir_1, dir_2, rel_path = path.partition("resources")
      if rel_path:
          return  dir_1 + dir_2, rel_path

      #  The same as the above but just looking for java
      (dir_1, dir_2, rel_path) = path.partition("java")
      if rel_path:
          return  dir_1 + dir_2, rel_path

      return "", path

def _adjust_resources_path(path, resource_strip_prefix):
    if resource_strip_prefix:
      return _adjust_resources_path_by_strip_prefix(path,resource_strip_prefix)
    else:
      return _adjust_resources_path_by_default_prefixes(path)

def _add_resources_cmd(ctx):
    res_cmd = []
    for f in ctx.files.resources:
        c_dir, res_path = _adjust_resources_path(f.short_path, ctx.attr.resource_strip_prefix)
        target_path = res_path
        if target_path[0] == "/":
            target_path = target_path[1:]
        line = "{target_path}={c_dir}{res_path}\n".format(
            res_path=res_path,
            target_path=target_path,
            c_dir=c_dir)
        res_cmd.extend([line])
    return "".join(res_cmd)

def _build_nosrc_jar(ctx, buildijar):
    resources = _add_resources_cmd(ctx)
    ijar_cmd = ""
    if buildijar:
        ijar_cmd = "\ncp {jar_output} {ijar_output}\n".format(
          jar_output=ctx.outputs.jar.path,
          ijar_output=ctx.outputs.ijar.path)

    # this ensures the file is not empty
    resources += "META-INF/MANIFEST.MF=%s\n" % ctx.outputs.manifest.path

    zipper_arg_path = ctx.actions.declare_file("%s_zipper_args" % ctx.label.name)
    ctx.actions.write(zipper_arg_path, resources)
    cmd = """
rm -f {jar_output}
{zipper} c {jar_output} @{path}
# ensures that empty src targets still emit a statsfile
touch {statsfile}
""" + ijar_cmd

    cmd = cmd.format(
        path = zipper_arg_path.path,
        jar_output=ctx.outputs.jar.path,
        zipper=ctx.executable._zipper.path,
        statsfile=ctx.outputs.statsfile.path,
        )

    outs = [ctx.outputs.jar, ctx.outputs.statsfile]
    if buildijar:
        outs.extend([ctx.outputs.ijar])

    inputs = ctx.files.resources + [
        ctx.outputs.manifest,
        ctx.executable._zipper,
        zipper_arg_path
      ]

    ctx.actions.run_shell(
        inputs=inputs,
        outputs=outs,
        command=cmd,
        progress_message="scala %s" % ctx.label,
        arguments=[])


def _collect_plugin_paths(plugins):
    paths = []
    for p in plugins:
        if hasattr(p, "path"):
            paths.append(p)
        elif hasattr(p, "scala"):
            paths.append(p.scala.outputs.jar)
        elif hasattr(p, "java"):
            paths.extend([j.class_jar for j in p.java.outputs.jars])
        # support http_file pointed at a jar. http_jar uses ijar,
        # which breaks scala macros
        elif hasattr(p, "files"):
            paths.extend([f for f in p.files if not_sources_jar(f.basename)])
    return depset(paths)


def _expand_location(ctx, flags):
  return [ctx.expand_location(f, ctx.attr.data) for f in flags]

def _join_path(args, sep=","):
    return sep.join([f.path for f in args])

def _compile(ctx, cjars, dep_srcjars, buildijar, transitive_compile_jars, labels, implicit_junit_deps_needed_for_java_compilation):
    ijar_output_path = ""
    ijar_cmd_path = ""
    if buildijar:
        ijar_output_path = ctx.outputs.ijar.path
        ijar_cmd_path = ctx.executable._ijar.path

    java_srcs = _java_filetype.filter(ctx.files.srcs)
    sources = _scala_filetype.filter(ctx.files.srcs) + java_srcs
    srcjars = _srcjar_filetype.filter(ctx.files.srcs)
    all_srcjars = depset(srcjars, transitive = [dep_srcjars])
    # look for any plugins:
    plugins = _collect_plugin_paths(ctx.attr.plugins)
    dependency_analyzer_plugin_jars = []
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
        dependency_analyzer_plugin_jars = ctx.files._dependency_analyzer_plugin
        compiler_classpath_jars = transitive_compile_jars

        direct_jars = _join_path(cjars.to_list())
        transitive_cjars_list = transitive_compile_jars.to_list()
        indirect_jars = _join_path(transitive_cjars_list)
        indirect_targets = ",".join([labels[j.path] for j in transitive_cjars_list])
        current_target = str(ctx.label)

        optional_scalac_args = """
DirectJars: {direct_jars}
IndirectJars: {indirect_jars}
IndirectTargets: {indirect_targets}
CurrentTarget: {current_target}
        """.format(
              direct_jars=direct_jars,
              indirect_jars=indirect_jars,
              indirect_targets=indirect_targets,
              current_target = current_target
              )

    plugin_arg = _join_path(plugins.to_list())

    separator = ctx.configuration.host_path_separator
    compiler_classpath = _join_path(compiler_classpath_jars.to_list(), separator)

    toolchain = ctx.toolchains['@io_bazel_rules_scala//scala:toolchain_type']
    scalacopts = toolchain.scalacopts + ctx.attr.scalacopts

    scalac_args = """
Classpath: {cp}
ClasspathResourceSrcs: {classpath_resource_src}
EnableIjar: {enableijar}
Files: {files}
IjarCmdPath: {ijar_cmd_path}
IjarOutput: {ijar_out}
JarOutput: {out}
JavaFiles: {java_files}
Manifest: {manifest}
Plugins: {plugin_arg}
PrintCompileTime: {print_compile_time}
ResourceDests: {resource_dest}
ResourceJars: {resource_jars}
ResourceSrcs: {resource_src}
ResourceShortPaths: {resource_short_paths}
ResourceStripPrefix: {resource_strip_prefix}
ScalacOpts: {scala_opts}
SourceJars: {srcjars}
DependencyAnalyzerMode: {dependency_analyzer_mode}
StatsfileOutput: {statsfile_output}
""".format(
        out=ctx.outputs.jar.path,
        manifest=ctx.outputs.manifest.path,
        scala_opts=",".join(scalacopts),
        print_compile_time=ctx.attr.print_compile_time,
        plugin_arg=plugin_arg,
        cp=compiler_classpath,
        classpath_resource_src=_join_path(classpath_resources),
        files=_join_path(sources),
        enableijar=buildijar,
        ijar_out=ijar_output_path,
        ijar_cmd_path=ijar_cmd_path,
        srcjars=_join_path(all_srcjars.to_list()),
        java_files=_join_path(java_srcs),
        # the resource paths need to be aligned in order
        resource_src=",".join([f.path for f in ctx.files.resources]),
        resource_short_paths=",".join([f.short_path for f in ctx.files.resources]),
        resource_dest=",".join(
          [_adjust_resources_path_by_default_prefixes(f.short_path)[1] for f in ctx.files.resources]
          ),
        resource_strip_prefix=ctx.attr.resource_strip_prefix,
        resource_jars=_join_path(ctx.files.resource_jars),
        dependency_analyzer_mode = dependency_analyzer_mode,
        statsfile_output = ctx.outputs.statsfile.path
        )
    argfile = ctx.actions.declare_file(
      "%s_worker_input" % ctx.label.name,
      sibling = ctx.outputs.jar
    )

    ctx.actions.write(output=argfile, content=scalac_args + optional_scalac_args)

    outs = [ctx.outputs.jar, ctx.outputs.statsfile]
    if buildijar:
        outs.extend([ctx.outputs.ijar])
    ins = (compiler_classpath_jars.to_list() +
           dep_srcjars.to_list() +
           list(srcjars) +
           list(sources) +
           ctx.files.srcs +
           ctx.files.plugins +
           dependency_analyzer_plugin_jars +
           classpath_resources +
           ctx.files.resources +
           ctx.files.resource_jars +
           ctx.files._java_runtime +
           [ctx.outputs.manifest,
            ctx.executable._ijar,
            argfile])
    ctx.actions.run(
        inputs=ins,
        outputs=outs,
        executable=ctx.executable._scalac,
        mnemonic="Scalac",
        progress_message="scala %s" % ctx.label,
        execution_requirements={"supports-workers": "1"},
        #  when we run with a worker, the `@argfile.path` is removed and passed
        #  line by line as arguments in the protobuf. In that case,
        #  the rest of the arguments are passed to the process that
        #  starts up and stays resident.

        # In either case (worker or not), they will be jvm flags which will
        # be correctly handled since the executable is a jvm app that will
        # consume the flags on startup.

        arguments=["--jvm_flag=%s" % f for f in _expand_location(ctx, ctx.attr.scalac_jvm_flags)] + ["@" + argfile.path],
      )

    if buildijar:
        scala_output = ctx.outputs.ijar
    else:
        scala_output = ctx.outputs.jar
    java_jar = try_to_compile_java_jar(ctx,
                                       scala_output,
                                       all_srcjars,
                                       java_srcs,
                                       implicit_junit_deps_needed_for_java_compilation)
    return java_jar


def _interim_java_provider_for_java_compilation(scala_output):
    # This is needed because Bazel >=0.7.0 requires ctx.actions and a Java
    # toolchain. Fortunately, the same change that added this requirement also
    # added this field to the Java provider so we can use it to test which
    # Bazel version we are running under.
    test_provider = java_common.create_provider()
    if hasattr(test_provider, "full_compile_jars"):
      return java_common.create_provider(
          use_ijar = False,
          compile_time_jars = [scala_output],
          runtime_jars = [],
      )
    else:
      return java_common.create_provider(
          compile_time_jars = [scala_output],
          runtime_jars = [],
      )

def try_to_compile_java_jar(ctx,
                            scala_output,
                            all_srcjars,
                            java_srcs,
                            implicit_junit_deps_needed_for_java_compilation):
    if not java_srcs and not all_srcjars:
      return False

    providers_of_dependencies = collect_java_providers_of(ctx.attr.deps)
    providers_of_dependencies += collect_java_providers_of(implicit_junit_deps_needed_for_java_compilation)
    scala_sources_java_provider = _interim_java_provider_for_java_compilation(scala_output)
    providers_of_dependencies += [scala_sources_java_provider]

    full_java_jar = ctx.actions.declare_file(ctx.label.name + "_java.jar")

    provider = java_common.compile(
                ctx,
                source_jars = all_srcjars.to_list(),
                source_files = java_srcs,
                output = full_java_jar,
                javac_opts = _expand_location(ctx, ctx.attr.javacopts + ctx.attr.javac_jvm_flags + java_common.default_javac_opts(ctx, java_toolchain_attr = "_java_toolchain")),
                deps = providers_of_dependencies,
                #exports can be empty since the manually created provider exposes exports
                #needs to be empty since we want the provider.compile_jars to only contain the sources ijar
                #workaround until https://github.com/bazelbuild/bazel/issues/3528 is resolved
                exports = [],
                java_toolchain = ctx.attr._java_toolchain,
                host_javabase = ctx.attr._host_javabase,
                strict_deps = ctx.fragments.java.strict_java_deps,
    )
    return struct(jar = full_java_jar, ijar = provider.compile_jars.to_list().pop())

def collect_java_providers_of(deps):
    providers = []
    for dep in deps:
        if java_common.provider in dep:
          providers.append(dep[java_common.provider])
    return providers

def _compile_or_empty(ctx, jars, srcjars, buildijar, transitive_compile_jars, jars2labels, implicit_junit_deps_needed_for_java_compilation):
    # We assume that if a srcjar is present, it is not empty
    if len(ctx.files.srcs) + len(srcjars.to_list()) == 0:
        _build_nosrc_jar(ctx, buildijar)
        #  no need to build ijar when empty
        return struct(ijar=ctx.outputs.jar,
                      class_jar=ctx.outputs.jar,
                      java_jar=False,
                      full_jars=[ctx.outputs.jar],
                      ijars=[ctx.outputs.jar])
    else:
        java_jar = _compile(ctx, jars, srcjars, buildijar, transitive_compile_jars, jars2labels, implicit_junit_deps_needed_for_java_compilation)
        ijar = None
        if buildijar:
            ijar = ctx.outputs.ijar
        else:
            #  macro code needs to be available at compile-time,
            #  so set ijar == jar
            ijar = ctx.outputs.jar
        full_jars = [ctx.outputs.jar]
        ijars = [ijar]
        if java_jar:
          full_jars += [java_jar.jar]
          ijars += [java_jar.ijar]
        return struct(ijar=ijar,
                      class_jar=ctx.outputs.jar,
                      java_jar=java_jar,
                      full_jars=full_jars,
                      ijars=ijars)

def _build_deployable(ctx, jars_list):
    # This calls bazels singlejar utility.
    # For a full list of available command line options see:
    # https://github.com/bazelbuild/bazel/blob/master/src/java_tools/singlejar/java/com/google/devtools/build/singlejar/SingleJar.java#L311
    args = ["--normalize", "--sources"]
    args.extend([j.path for j in jars_list])
    if getattr(ctx.attr, "main_class", ""):
        args.extend(["--main_class", ctx.attr.main_class])
    args.extend(["--output", ctx.outputs.deploy_jar.path])
    ctx.actions.run(
        inputs=jars_list,
        outputs=[ctx.outputs.deploy_jar],
        executable=ctx.executable._singlejar,
        mnemonic="ScalaDeployJar",
        progress_message="scala deployable %s" % ctx.label,
        arguments=args)

def write_manifest(ctx):
    # TODO(bazel-team): I don't think this classpath is what you want
    manifest = "Class-Path: \n"
    if getattr(ctx.attr, "main_class", ""):
        manifest += "Main-Class: %s\n" % ctx.attr.main_class

    ctx.actions.write(
        output=ctx.outputs.manifest,
        content=manifest)

def _path_is_absolute(path):
    # Returns true for absolute path in Linux/Mac (i.e., '/') or Windows (i.e.,
    # 'X:\' or 'X:/' where 'X' is a letter), false otherwise.
    if len(path) >= 1 and path[0] == "/":
        return True
    if len(path) >= 3 \
            and path[0].isalpha() \
            and path[1] == ":" \
            and (path[2] == "/" or path[2] == "\\"):
        return True

    return False

def _runfiles_root(ctx):
    return "${TEST_SRCDIR}/%s" % ctx.workspace_name

def _write_java_wrapper(ctx, args="", wrapper_preamble=""):
    """This creates a wrapper that sets up the correct path
       to stand in for the java command."""

    java_path = str(ctx.attr._java_runtime[java_common.JavaRuntimeInfo].java_executable_runfiles_path)
    if _path_is_absolute(java_path):
      javabin = java_path
    else:
      runfiles_root = _runfiles_root(ctx)
      javabin = "%s/%s" % (runfiles_root, java_path)


    exec_str = ""
    if wrapper_preamble == "":
      exec_str = "exec "

    wrapper = ctx.actions.declare_file(ctx.label.name + "_wrapper.sh")
    ctx.actions.write(
        output = wrapper,
        content = """#!/bin/bash
{preamble}

{exec_str}{javabin} "$@" {args}
""".format(
            preamble=wrapper_preamble,
            exec_str=exec_str,
            javabin=javabin,
            args=args,
        ),
        is_executable = True
    )
    return wrapper

def _write_executable(ctx, rjars, main_class, jvm_flags, wrapper):
    template = ctx.attr._java_stub_template.files.to_list()[0]
    # RUNPATH is defined here:
    # https://github.com/bazelbuild/bazel/blob/0.4.5/src/main/java/com/google/devtools/build/lib/bazel/rules/java/java_stub_template.txt#L227
    classpath = ":".join(["${RUNPATH}%s" % (j.short_path) for j in rjars.to_list()])
    jvm_flags = " ".join([ctx.expand_location(f, ctx.attr.data) for f in jvm_flags])
    ctx.actions.expand_template(
        template = template,
        output = ctx.outputs.executable,
        substitutions = {
            "%classpath%": classpath,
            "%java_start_class%": main_class,
            "%javabin%": "JAVABIN=%s/%s" % (_runfiles_root(ctx), wrapper.short_path),
            "%jvm_flags%": jvm_flags,
            "%needs_runfiles%": "",
            "%runfiles_manifest_only%": "",
            "%set_jacoco_metadata%": "",
            "%workspace_prefix%": ctx.workspace_name + "/",
        },
        is_executable = True,
    )

def collect_srcjars(targets):
    srcjars = []
    for target in targets:
        if hasattr(target, "srcjars"):
            srcjars.append(target.srcjars.srcjar)
    return depset(srcjars)

def add_labels_of_jars_to(jars2labels, dependency, all_jars, direct_jars):
  for jar in direct_jars:
    add_label_of_direct_jar_to(jars2labels, dependency, jar)
  for jar in all_jars:
    add_label_of_indirect_jar_to(jars2labels, dependency, jar)


def add_label_of_direct_jar_to(jars2labels, dependency, jar):
  jars2labels[jar.path] = dependency.label

def add_label_of_indirect_jar_to(jars2labels, dependency, jar):
 if label_already_exists(jars2labels, jar):
   return

 # skylark exposes only labels of direct dependencies.
 # to get labels of indirect dependencies we collect them from the providers transitively
 if provider_of_dependency_contains_label_of(dependency, jar):
   jars2labels[jar.path] = dependency[JarsToLabels].lookup[jar.path]
 else:
   jars2labels[jar.path] = "Unknown label of file {jar_path} which came from {dependency_label}".format(
       jar_path = jar.path,
       dependency_label = dependency.label
   )

def label_already_exists(jars2labels, jar):
  return jar.path in jars2labels

def provider_of_dependency_contains_label_of(dependency, jar):
  return JarsToLabels in dependency and jar.path in dependency[JarsToLabels].lookup

def dep_target_contains_ijar(dep_target):
  return (hasattr(dep_target, 'scala') and hasattr(dep_target.scala, 'outputs') and
          hasattr(dep_target.scala.outputs, 'ijar') and dep_target.scala.outputs.ijar)

# When import mavan_jar's for scala macros we have to use the jar:file requirement
# since bazel 0.6.0 this brings in the source jar too
# the scala compiler thinks a source jar can look like a package space
# causing a conflict between objects and packages warning
#  error: package cats contains object and package with same name: implicits
# one of them needs to be removed from classpath
# import cats.implicits._

def not_sources_jar(name):
  return "-sources.jar" not in name

def filter_not_sources(deps):
  return depset([dep for dep in deps.to_list() if not_sources_jar(dep.basename) ])

def _collect_runtime_jars(dep_targets):
  runtime_jars = []

  for dep_target in dep_targets:
    if java_common.provider in dep_target:
        runtime_jars.append(dep_target[java_common.provider].transitive_runtime_jars)
    else:
        # support http_file pointed at a jar. http_jar uses ijar,
        # which breaks scala macros
        runtime_jars.append(filter_not_sources(dep_target.files))

  return runtime_jars

def _collect_jars_when_dependency_analyzer_is_off(dep_targets):
  compile_jars = []
  runtime_jars = []

  for dep_target in dep_targets:
    if java_common.provider in dep_target:
        java_provider = dep_target[java_common.provider]
        compile_jars.append(java_provider.compile_jars)
        runtime_jars.append(java_provider.transitive_runtime_jars)
    else:
        # support http_file pointed at a jar. http_jar uses ijar,
        # which breaks scala macros
        compile_jars.append(filter_not_sources(dep_target.files))
        runtime_jars.append(filter_not_sources(dep_target.files))

  return struct(compile_jars = depset(transitive = compile_jars),
      transitive_runtime_jars = depset(transitive = runtime_jars),
      jars2labels = {},
      transitive_compile_jars = depset())

def _collect_jars_when_dependency_analyzer_is_on(dep_targets):
  transitive_compile_jars = []
  jars2labels = {}
  compile_jars = []
  runtime_jars = []

  for dep_target in dep_targets:
    current_dep_compile_jars = None
    current_dep_transitive_compile_jars = None

    if java_common.provider in dep_target:
        java_provider = dep_target[java_common.provider]
        current_dep_compile_jars = java_provider.compile_jars
        current_dep_transitive_compile_jars = java_provider.transitive_compile_time_jars
        runtime_jars.append(java_provider.transitive_runtime_jars)
    else:
        # support http_file pointed at a jar. http_jar uses ijar,
        # which breaks scala macros
        current_dep_compile_jars = filter_not_sources(dep_target.files)
        current_dep_transitive_compile_jars = filter_not_sources(dep_target.files)
        runtime_jars.append(filter_not_sources(dep_target.files))

    compile_jars.append(current_dep_compile_jars)
    transitive_compile_jars.append(current_dep_transitive_compile_jars)
    add_labels_of_jars_to(jars2labels, dep_target, current_dep_transitive_compile_jars.to_list(), current_dep_compile_jars.to_list())

  return struct(compile_jars = depset(transitive = compile_jars),
    transitive_runtime_jars = depset(transitive = runtime_jars),
    jars2labels = jars2labels,
    transitive_compile_jars = depset(transitive = transitive_compile_jars))

def collect_jars(dep_targets, dependency_analyzer_is_off = True):
    """Compute the runtime and compile-time dependencies from the given targets"""  # noqa

    if dependency_analyzer_is_off:
      return _collect_jars_when_dependency_analyzer_is_off(dep_targets)
    else:
      return _collect_jars_when_dependency_analyzer_is_on(dep_targets)

def is_dependency_analyzer_on(ctx):
  if (hasattr(ctx.attr,"_dependency_analyzer_plugin")
    # when the strict deps FT is removed the "default" check
    # will be removed since "default" will mean it's turned on
    and ctx.fragments.java.strict_java_deps != "default"
    and ctx.fragments.java.strict_java_deps != "off"):
    return True

def is_dependency_analyzer_off(ctx):
  return not is_dependency_analyzer_on(ctx)

# Extract very common code out from dependency analysis into single place
# automatically adds dependency on scala-library and scala-reflect
# collects jars from deps, runtime jars from runtime_deps, and
def _collect_jars_from_common_ctx(ctx, extra_deps = [], extra_runtime_deps = []):

    dependency_analyzer_is_off = is_dependency_analyzer_off(ctx)

    # Get jars from deps
    auto_deps = [ctx.attr._scalalib, ctx.attr._scalareflect]
    deps_jars = collect_jars(ctx.attr.deps + auto_deps + extra_deps, dependency_analyzer_is_off)
    (cjars, transitive_rjars, jars2labels, transitive_compile_jars) = (deps_jars.compile_jars, deps_jars.transitive_runtime_jars, deps_jars.jars2labels, deps_jars.transitive_compile_jars)

    transitive_rjars = depset(transitive = [transitive_rjars] + _collect_runtime_jars(ctx.attr.runtime_deps + extra_runtime_deps))

    return struct(compile_jars = cjars, transitive_runtime_jars = transitive_rjars, jars2labels=jars2labels, transitive_compile_jars = transitive_compile_jars)

def create_java_provider(scalaattr, transitive_compile_time_jars):
    # This is needed because Bazel >=0.7.0 requires ctx.actions and a Java
    # toolchain. Fortunately, the same change that added this requirement also
    # added this field to the Java provider so we can use it to test which
    # Bazel version we are running under.
    test_provider = java_common.create_provider()

    if hasattr(test_provider, "full_compile_jars"):
      return java_common.create_provider(
          use_ijar = False,
          compile_time_jars = scalaattr.compile_jars,
          runtime_jars = scalaattr.transitive_runtime_jars,
          transitive_compile_time_jars = depset(transitive = [transitive_compile_time_jars, scalaattr.compile_jars]),
          transitive_runtime_jars = scalaattr.transitive_runtime_jars,
      )
    else:
      return java_common.create_provider(
          compile_time_jars = scalaattr.compile_jars,
          runtime_jars = scalaattr.transitive_runtime_jars,
          transitive_compile_time_jars = transitive_compile_time_jars,
          transitive_runtime_jars = scalaattr.transitive_runtime_jars,
      )

# TODO: this should really be a bazel provider, but we are using old-style rule outputs
# we need to document better what the intellij dependencies on this code actually are
def create_scala_provider(
    ijar,
    class_jar,
    compile_jars,
    transitive_runtime_jars,
    deploy_jar,
    full_jars,
    statsfile):

    formatted_for_intellij = [struct(
        class_jar = jar,
        ijar = None,
        source_jar = None,
        source_jars = []) for jar in full_jars]

    rule_outputs = struct(
        ijar = ijar,
        class_jar = class_jar,
        deploy_jar = deploy_jar,
        jars = formatted_for_intellij,
        statsfile = statsfile,
    )
    # Note that, internally, rules only care about compile_jars and transitive_runtime_jars
    # in a similar manner as the java_library and JavaProvider
    return struct(
        outputs = rule_outputs,
        compile_jars = compile_jars,
        transitive_runtime_jars = transitive_runtime_jars,
        transitive_exports = [] #needed by intellij plugin
    )

def _lib(ctx, non_macro_lib):
    # Build up information from dependency-like attributes

    # This will be used to pick up srcjars from non-scala library
    # targets (like thrift code generation)
    srcjars = collect_srcjars(ctx.attr.deps)
    jars = _collect_jars_from_common_ctx(ctx)
    (cjars, transitive_rjars) = (jars.compile_jars, jars.transitive_runtime_jars)

    write_manifest(ctx)
    outputs = _compile_or_empty(ctx, cjars, srcjars, non_macro_lib, jars.transitive_compile_jars, jars.jars2labels, [])

    transitive_rjars = depset(outputs.full_jars, transitive = [transitive_rjars])

    _build_deployable(ctx, transitive_rjars.to_list())

    # Using transitive_files since transitive_rjars a depset and avoiding linearization
    runfiles = ctx.runfiles(
        transitive_files = transitive_rjars,
        collect_data = True,
    )

    # Add information from exports (is key that AFTER all build actions/runfiles analysis)
    # Since after, will not show up in deploy_jar or old jars runfiles
    # Notice that compile_jars is intentionally transitive for exports
    exports_jars = collect_jars(ctx.attr.exports)
    transitive_rjars = depset(transitive = [transitive_rjars, exports_jars.transitive_runtime_jars])

    scalaattr = create_scala_provider(
        ijar = outputs.ijar,
        class_jar = outputs.class_jar,
        compile_jars = depset(outputs.ijars, transitive = [exports_jars.compile_jars]),
        transitive_runtime_jars = transitive_rjars,
        deploy_jar = ctx.outputs.deploy_jar,
        full_jars = outputs.full_jars,
        statsfile = ctx.outputs.statsfile)

    java_provider = create_java_provider(scalaattr, jars.transitive_compile_jars)

    return struct(
        files = depset([ctx.outputs.jar]),  # Here is the default output
        scala = scalaattr,
        providers = [
            JarsToLabels(lookup = jars.jars2labels),
            java_provider],
        runfiles = runfiles,
        # This is a free monoid given to the graph for the purpose of
        # extensibility. This is necessary when one wants to create
        # new targets which want to leverage a scala_library. For example,
        # new_target1 -> scala_library -> new_target2. There might be
        # information that new_target2 needs to get from new_target1,
        # but we do not want to have to change scala_library to pass
        # this information through. extra_information allows passing
        # this information through, and it is up to the new_targets
        # to filter and make sense of this information.
        extra_information=_collect_extra_information(ctx.attr.deps),
      )


def _collect_extra_information(targets):
  r = []
  for target in targets:
    if hasattr(target, "extra_information"):
      r.extend(target.extra_information)
  return r

def _scala_library_impl(ctx):
  return _lib(ctx, True)

def _scala_macro_library_impl(ctx):
  return _lib(ctx, False)  # don't build the ijar for macros

# Common code shared by all scala binary implementations.
def _scala_binary_common(ctx, cjars, rjars, transitive_compile_time_jars, jars2labels, java_wrapper, implicit_junit_deps_needed_for_java_compilation = []):
  write_manifest(ctx)
  outputs = _compile_or_empty(ctx, cjars, depset(), False, transitive_compile_time_jars, jars2labels, implicit_junit_deps_needed_for_java_compilation)  # no need to build an ijar for an executable
  rjars = depset(outputs.full_jars, transitive = [rjars])

  _build_deployable(ctx, rjars.to_list())

  runfiles = ctx.runfiles(
      transitive_files = depset([ctx.outputs.executable, java_wrapper] + ctx.files._java_runtime, transitive = [rjars]),
      collect_data = True)

  scalaattr = create_scala_provider(
      ijar = outputs.class_jar, # we aren't using ijar here
      class_jar = outputs.class_jar,
      compile_jars = depset(outputs.ijars),
      transitive_runtime_jars = rjars,
      deploy_jar = ctx.outputs.deploy_jar,
      full_jars = outputs.full_jars,
      statsfile = ctx.outputs.statsfile)

  java_provider = create_java_provider(scalaattr, transitive_compile_time_jars)

  return struct(
      files=depset([ctx.outputs.executable]),
      providers = [
          JarsToLabels(lookup = jars2labels),
          java_provider],
      scala = scalaattr,
      transitive_rjars = rjars, #calling rules need this for the classpath in the launcher
      runfiles=runfiles)

def _scala_binary_impl(ctx):
  jars = _collect_jars_from_common_ctx(ctx)
  (cjars, transitive_rjars) = (jars.compile_jars, jars.transitive_runtime_jars)

  wrapper = _write_java_wrapper(ctx, "", "")
  out = _scala_binary_common(ctx, cjars, transitive_rjars, jars.transitive_compile_jars, jars.jars2labels, wrapper)
  _write_executable(
      ctx = ctx,
      rjars = out.transitive_rjars,
      main_class = ctx.attr.main_class,
      jvm_flags = ctx.attr.jvm_flags,
      wrapper = wrapper
  )
  return out

def _scala_repl_impl(ctx):
  # need scala-compiler for MainGenericRunner below
  jars = _collect_jars_from_common_ctx(ctx, extra_runtime_deps = [ctx.attr._scalacompiler])
  (cjars, transitive_rjars) = (jars.compile_jars, jars.transitive_runtime_jars)

  args = " ".join(ctx.attr.scalacopts)
  wrapper = _write_java_wrapper(ctx, args, wrapper_preamble = """
# save stty like in bin/scala
saved_stty=$(stty -g 2>/dev/null)
if [[ ! $? ]]; then
  saved_stty=""
fi
function finish() {
  if [[ "$saved_stty" != "" ]]; then
    stty $saved_stty
    saved_stty=""
  fi
}
trap finish EXIT
""")

  out = _scala_binary_common(ctx, cjars, transitive_rjars, jars.transitive_compile_jars, jars.jars2labels, wrapper)
  _write_executable(
      ctx = ctx,
      rjars = out.transitive_rjars,
      main_class = "scala.tools.nsc.MainGenericRunner",
      jvm_flags = ["-Dscala.usejavacp=true"] + ctx.attr.jvm_flags,
      wrapper = wrapper
  )

  return out

def _scala_test_flags(ctx):
    # output report test duration
    flags = "-oD"
    if ctx.attr.full_stacktraces:
        flags += "F"
    else:
        flags += "S"
    if not ctx.attr.colors:
        flags += "W"
    return flags

def _scala_test_impl(ctx):
    if len(ctx.attr.suites) != 0:
        print(
          "suites attribute is deprecated. All scalatest test suites are run"
        )
    jars = _collect_jars_from_common_ctx(ctx,
        extra_runtime_deps = [ctx.attr._scalatest_reporter, ctx.attr._scalatest_runner],
    )
    (cjars, transitive_rjars, transitive_compile_jars, jars_to_labels) = (jars.compile_jars, jars.transitive_runtime_jars,
      jars.transitive_compile_jars, jars.jars2labels)
    # _scalatest is an http_jar, so its compile jar is run through ijar
    # however, contains macros, so need to handle separately
    scalatest_jars = collect_jars([ctx.attr._scalatest]).transitive_runtime_jars
    cjars = depset(transitive = [cjars, scalatest_jars])
    transitive_rjars = depset(transitive = [transitive_rjars, scalatest_jars])

    if is_dependency_analyzer_on(ctx):
      transitive_compile_jars = depset(transitive = [scalatest_jars, transitive_compile_jars])
      scalatest_jars_list = scalatest_jars.to_list()
      add_labels_of_jars_to(jars_to_labels, ctx.attr._scalatest, scalatest_jars_list, scalatest_jars_list)

    args = " ".join([
        "-R \"{path}\"".format(path=ctx.outputs.jar.short_path),
        _scala_test_flags(ctx),
        "-C io.bazel.rules.scala.JUnitXmlReporter ",
    ])
    # main_class almost has to be "org.scalatest.tools.Runner" due to args....
    wrapper = _write_java_wrapper(ctx, args, "")
    out = _scala_binary_common(ctx, cjars, transitive_rjars, transitive_compile_jars, jars_to_labels, wrapper)
    _write_executable(
        ctx = ctx,
        rjars = out.transitive_rjars,
        main_class = ctx.attr.main_class,
        jvm_flags = ctx.attr.jvm_flags,
        wrapper = wrapper
    )
    return out

def _gen_test_suite_flags_based_on_prefixes_and_suffixes(ctx, archives):
    serialized_archives = _serialize_archives_short_path(archives)
    return struct(
        testSuiteFlag = "-Dbazel.test_suite=%s" % ctx.attr.suite_class,
        archiveFlag = "-Dbazel.discover.classes.archives.file.paths=%s" % serialized_archives,
        prefixesFlag = "-Dbazel.discover.classes.prefixes=%s" % ",".join(ctx.attr.prefixes),
        suffixesFlag = "-Dbazel.discover.classes.suffixes=%s" % ",".join(ctx.attr.suffixes),
        printFlag = "-Dbazel.discover.classes.print.discovered=%s" % ctx.attr.print_discovered_classes)

def _serialize_archives_short_path(archives):
  archives_short_path = ""
  for archive in archives: archives_short_path += archive.class_jar.short_path + ","
  return archives_short_path[:-1] #remove redundant comma

def _scala_junit_test_impl(ctx):
    if (not(ctx.attr.prefixes) and not(ctx.attr.suffixes)):
      fail("Setting at least one of the attributes ('prefixes','suffixes') is required")
    jars = _collect_jars_from_common_ctx(ctx,
        extra_deps = [ctx.attr._junit, ctx.attr._hamcrest, ctx.attr.suite_label, ctx.attr._bazel_test_runner],
    )
    (cjars, transitive_rjars) = (jars.compile_jars, jars.transitive_runtime_jars)
    implicit_junit_deps_needed_for_java_compilation = [ctx.attr._junit, ctx.attr._hamcrest]

    wrapper = _write_java_wrapper(ctx, "", "")
    out =  _scala_binary_common(ctx, cjars, transitive_rjars, jars.transitive_compile_jars, jars.jars2labels, wrapper, implicit_junit_deps_needed_for_java_compilation)
    test_suite = _gen_test_suite_flags_based_on_prefixes_and_suffixes(ctx, out.scala.outputs.jars)
    launcherJvmFlags = ["-ea", test_suite.archiveFlag, test_suite.prefixesFlag, test_suite.suffixesFlag, test_suite.printFlag, test_suite.testSuiteFlag]
    _write_executable(
        ctx = ctx,
        rjars = out.transitive_rjars,
        main_class = "com.google.testing.junit.runner.BazelTestRunner",
        jvm_flags = launcherJvmFlags + ctx.attr.jvm_flags,
        wrapper = wrapper
    )

    return out

_launcher_template = {
  "_java_stub_template": attr.label(default=Label("@java_stub_template//file")),
}

_implicit_deps = {
  "_singlejar": attr.label(executable=True, cfg="host", default=Label("@bazel_tools//tools/jdk:singlejar"), allow_files=True),
  "_ijar": attr.label(executable=True, cfg="host", default=Label("@bazel_tools//tools/jdk:ijar"), allow_files=True),
  "_scalac": attr.label(executable=True, cfg="host", default=Label("//src/java/io/bazel/rulesscala/scalac"), allow_files=True),
  "_scalalib": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scala/scala_library"), allow_files=True),
  "_scalacompiler": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scala/scala_compiler"), allow_files=True),
  "_scalareflect": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scala/scala_reflect"), allow_files=True),
  "_zipper": attr.label(executable=True, cfg="host", default=Label("@bazel_tools//tools/zip:zipper"), allow_files=True),
  "_java_toolchain": attr.label(default = Label("@bazel_tools//tools/jdk:current_java_toolchain")),
  "_host_javabase": attr.label(default = Label("@bazel_tools//tools/jdk:current_java_runtime"), cfg="host"),
  "_java_runtime": attr.label(default = Label("@bazel_tools//tools/jdk:current_java_runtime"))
}

# Single dep to allow IDEs to pickup all the implicit dependencies.
_resolve_deps = {
  "_scala_toolchain" : attr.label_list(default=[
    Label("//external:io_bazel_rules_scala/dependency/scala/scala_library"),
  ], allow_files=False),
}

_test_resolve_deps = {
  "_scala_toolchain" : attr.label_list(default=[
    Label("//external:io_bazel_rules_scala/dependency/scala/scala_library"),
    Label("//external:io_bazel_rules_scala/dependency/scalatest/scalatest"),
  ], allow_files=False),
}

_junit_resolve_deps = {
  "_scala_toolchain" : attr.label_list(default=[
    Label("//external:io_bazel_rules_scala/dependency/scala/scala_library"),
    Label("//external:io_bazel_rules_scala/dependency/junit/junit"),
    Label("//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core"),
  ], allow_files=False),
}

# Common attributes reused across multiple rules.
_common_attrs_for_plugin_bootstrapping = {
  "srcs": attr.label_list(
      allow_files=_scala_srcjar_filetype),
  "deps": attr.label_list(),
  "plugins": attr.label_list(allow_files=_jar_filetype),
  "runtime_deps": attr.label_list(),
  "data": attr.label_list(allow_files=True, cfg="data"),
  "resources": attr.label_list(allow_files=True),
  "resource_strip_prefix": attr.string(),
  "resource_jars": attr.label_list(allow_files=True),
  "scalacopts":attr.string_list(),
  "javacopts":attr.string_list(),
  "jvm_flags": attr.string_list(),
  "scalac_jvm_flags": attr.string_list(),
  "javac_jvm_flags": attr.string_list(),
  "print_compile_time": attr.bool(default=False, mandatory=False),
}

_common_attrs = {}
_common_attrs.update(_common_attrs_for_plugin_bootstrapping)
_common_attrs.update({
  # using stricts scala deps is done by using command line flag called 'strict_java_deps'
  # switching mode to "on" means that ANY API change in a target's transitive dependencies will trigger a recompilation of that target,
  # on the other hand any internal change (i.e. on code that ijar omits) WON’T trigger recompilation by transitive dependencies
  "_dependency_analyzer_plugin": attr.label(default=Label("@io_bazel_rules_scala//third_party/plugin/src/main:dependency_analyzer"), allow_files=_jar_filetype, mandatory=False),
})

library_attrs = {
  "main_class": attr.string(),
  "exports": attr.label_list(allow_files=False),
}

common_outputs = {
  "jar": "%{name}.jar",
  "deploy_jar": "%{name}_deploy.jar",
  "manifest": "%{name}_MANIFEST.MF",
  "statsfile": "%{name}.statsfile",
}

library_outputs = {}
library_outputs.update(common_outputs)
library_outputs.update({
  "ijar": "%{name}_ijar.jar",
})

_scala_library_attrs = {}
_scala_library_attrs.update(_implicit_deps)
_scala_library_attrs.update(_common_attrs)
_scala_library_attrs.update(library_attrs)
_scala_library_attrs.update(_resolve_deps)
scala_library = rule(
  implementation=_scala_library_impl,
  attrs=_scala_library_attrs,
  outputs=library_outputs,
  fragments = ["java"],
  toolchains = ['@io_bazel_rules_scala//scala:toolchain_type'],
)

# the scala compiler plugin used for dependency analysis is compiled using `scala_library`.
# in order to avoid cyclic dependencies `scala_library_for_plugin_bootstrapping` was created for this purpose,
# which does not contain plugin related attributes, and thus avoids the cyclic dependency issue
_scala_library_for_plugin_bootstrapping_attrs = {}
_scala_library_for_plugin_bootstrapping_attrs.update(_implicit_deps)
_scala_library_for_plugin_bootstrapping_attrs.update(library_attrs)
_scala_library_for_plugin_bootstrapping_attrs.update(_resolve_deps)
_scala_library_for_plugin_bootstrapping_attrs.update(_common_attrs_for_plugin_bootstrapping)
scala_library_for_plugin_bootstrapping = rule(
  implementation=_scala_library_impl,
  attrs= _scala_library_for_plugin_bootstrapping_attrs,
  outputs=library_outputs,
  fragments = ["java"],
  toolchains = ['@io_bazel_rules_scala//scala:toolchain_type'],
)

_scala_macro_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(allow_files=False),
}
_scala_macro_library_attrs.update(_implicit_deps)
_scala_macro_library_attrs.update(_common_attrs)
_scala_macro_library_attrs.update(library_attrs)
_scala_macro_library_attrs.update(_resolve_deps)
scala_macro_library = rule(
  implementation=_scala_macro_library_impl,
  attrs= _scala_macro_library_attrs,
  outputs= common_outputs,
  fragments = ["java"],
  toolchains = ['@io_bazel_rules_scala//scala:toolchain_type'],
)

_scala_binary_attrs = {
    "main_class": attr.string(mandatory=True),
    "classpath_resources": attr.label_list(allow_files=True),
}
_scala_binary_attrs.update(_launcher_template)
_scala_binary_attrs.update(_implicit_deps)
_scala_binary_attrs.update(_common_attrs)
_scala_binary_attrs.update(_resolve_deps)
scala_binary = rule(
  implementation=_scala_binary_impl,
  attrs= _scala_binary_attrs,
  outputs= common_outputs,
  executable=True,
  fragments = ["java"],
  toolchains = ['@io_bazel_rules_scala//scala:toolchain_type'],
)

_scala_test_attrs = {
    "main_class": attr.string(default="io.bazel.rulesscala.scala_test.Runner"),
    "suites": attr.string_list(),
    "colors": attr.bool(default=True),
    "full_stacktraces": attr.bool(default=True),
    "_scalatest": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scalatest/scalatest"), allow_files=True),
    "_scalatest_runner": attr.label(executable=True, cfg="host", default=Label("//src/java/io/bazel/rulesscala/scala_test:runner.jar"), allow_files=True),
    "_scalatest_reporter": attr.label(default=Label("//scala/support:test_reporter")),
}
_scala_test_attrs.update(_launcher_template)
_scala_test_attrs.update(_implicit_deps)
_scala_test_attrs.update(_common_attrs)
_scala_test_attrs.update(_test_resolve_deps)
scala_test = rule(
  implementation=_scala_test_impl,
  attrs= _scala_test_attrs,
  outputs= common_outputs,
  executable=True,
  test=True,
  fragments = ["java"],
  toolchains = ['@io_bazel_rules_scala//scala:toolchain_type'],
)

_scala_repl_attrs = {}
_scala_repl_attrs.update(_launcher_template)
_scala_repl_attrs.update(_implicit_deps)
_scala_repl_attrs.update(_common_attrs)
_scala_repl_attrs.update(_resolve_deps)
scala_repl = rule(
  implementation=_scala_repl_impl,
  attrs= _scala_repl_attrs,
  outputs= common_outputs,
  executable=True,
  fragments = ["java"],
  toolchains = ['@io_bazel_rules_scala//scala:toolchain_type'],
)

SCALA_BUILD_FILE = """
# scala.BUILD
java_import(
    name = "scala-xml",
    jars = ["lib/scala-xml_2.11-1.0.5.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-parser-combinators",
    jars = ["lib/scala-parser-combinators_2.11-1.0.4.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-library",
    jars = ["lib/scala-library.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-compiler",
    jars = ["lib/scala-compiler.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "scala-reflect",
    jars = ["lib/scala-reflect.jar"],
    visibility = ["//visibility:public"],
)
"""

def scala_repositories():
  native.new_http_archive(
    name = "scala",
    strip_prefix = "scala-2.11.11",
    sha256 = "12037ca64c68468e717e950f47fc77d5ceae5e74e3bdca56f6d02fd5bfd6900b",
    url = "https://downloads.lightbend.com/scala/2.11.11/scala-2.11.11.tgz",
    build_file_content = SCALA_BUILD_FILE,
  )

  # scalatest has macros, note http_jar is invoking ijar
  native.http_jar(
    name = "scalatest",
    url = "https://mirror.bazel.build/oss.sonatype.org/content/groups/public/org/scalatest/scalatest_2.11/2.2.6/scalatest_2.11-2.2.6.jar",
    sha256 = "f198967436a5e7a69cfd182902adcfbcb9f2e41b349e1a5c8881a2407f615962",
  )

  native.maven_server(
    name = "scalac_deps_maven_server",
    url = "https://mirror.bazel.build/repo1.maven.org/maven2/",
  )

  native.maven_jar(
    name = "scalac_rules_protobuf_java",
    artifact = "com.google.protobuf:protobuf-java:3.1.0",
    sha1 = "e13484d9da178399d32d2d27ee21a77cfb4b7873",
    server = "scalac_deps_maven_server",
  )

  # used by ScalacProcessor
  native.maven_jar(
      name = "scalac_rules_commons_io",
      artifact = "commons-io:commons-io:2.6",
      sha1 = "815893df5f31da2ece4040fe0a12fd44b577afaf",
      # bazel maven mirror doesn't have the commons_io artifact
#      server = "scalac_deps_maven_server",
    )

  # Template for binary launcher
  BAZEL_JAVA_LAUNCHER_VERSION = "0.4.5"
  java_stub_template_url = ("raw.githubusercontent.com/bazelbuild/bazel/" +
                            BAZEL_JAVA_LAUNCHER_VERSION +
                            "/src/main/java/com/google/devtools/build/lib/bazel/rules/java/" +
                            "java_stub_template.txt")
  native.http_file(
    name = "java_stub_template",
    urls = ["https://mirror.bazel.build/%s" % java_stub_template_url,
            "https://%s" % java_stub_template_url],
    sha256 = "f09d06d55cd25168427a323eb29d32beca0ded43bec80d76fc6acd8199a24489",
  )

  native.bind(name = "io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java", actual = "@scalac_rules_protobuf_java//jar")

  native.bind(name = "io_bazel_rules_scala/dependency/commons_io/commons_io", actual = "@scalac_rules_commons_io//jar")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/parser_combinators", actual = "@scala//:scala-parser-combinators")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/scala_compiler", actual = "@scala//:scala-compiler")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/scala_library", actual = "@scala//:scala-library")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/scala_reflect", actual = "@scala//:scala-reflect")

  native.bind(name = "io_bazel_rules_scala/dependency/scala/scala_xml", actual = "@scala//:scala-xml")

  native.bind(name = "io_bazel_rules_scala/dependency/scalatest/scalatest", actual = "@scalatest//jar")

def _sanitize_string_for_usage(s):
    res_array = []
    for idx in range(len(s)):
        c = s[idx]
        if c.isalnum() or c == ".":
            res_array.append(c)
        else:
            res_array.append("_")
    return "".join(res_array)

# This auto-generates a test suite based on the passed set of targets
# we will add a root test_suite with the name of the passed name
def scala_test_suite(name, srcs = [], deps = [], runtime_deps = [], data = [], resources = [],
                     scalacopts = [], jvm_flags = [], visibility = None, size = None,
                     colors=True, full_stacktraces=True):
    ts = []
    for test_file in srcs:
        n = "%s_test_suite_%s" % (name, _sanitize_string_for_usage(test_file))
        scala_test(name = n, srcs = [test_file], deps = deps, runtime_deps = runtime_deps, resources=resources, scalacopts=scalacopts, jvm_flags=jvm_flags, visibility=visibility, size=size, colors=colors, full_stacktraces=full_stacktraces)
        ts.append(n)
    native.test_suite(name = name, tests = ts, visibility = visibility)

# Scala library suite generates a series of scala libraries
# then it depends on them with a meta one which exports all the sub targets
def scala_library_suite(name,
                        srcs = [],
                        deps = [],
                        exports = [],
                        plugins = [],
                        runtime_deps = [],
                        data = [],
                        resources = [],
                        resource_strip_prefix = "",
                        scalacopts = [],
                        javacopts = [],
                        jvm_flags = [],
                        print_compile_time = False,
                        visibility = None
                        ):
    ts = []
    for src_file in srcs:
        n = "%s_lib_%s" % (name, _sanitize_string_for_usage(src_file))
        scala_library(name = n,
                      srcs = [src_file],
                      deps = deps,
                      plugins = plugins,
                      runtime_deps = runtime_deps,
                      data = data,
                      resources=resources,
                      resource_strip_prefix = resource_strip_prefix,
                      scalacopts = scalacopts,
                      javacopts = javacopts,
                      jvm_flags = jvm_flags,
                      print_compile_time = print_compile_time,
                      visibility=visibility,
                      exports=exports
                      )
        ts.append(n)
    scala_library(name = name, deps = ts, exports = exports + ts, visibility = visibility)

_scala_junit_test_attrs = {
    "prefixes": attr.string_list(default=[]),
    "suffixes": attr.string_list(default=[]),
    "suite_label": attr.label(default=Label("//src/java/io/bazel/rulesscala/test_discovery:test_discovery")),
    "suite_class": attr.string(default="io.bazel.rulesscala.test_discovery.DiscoveredTestSuite"),
    "print_discovered_classes": attr.bool(default=False, mandatory=False),
    "_junit": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/junit/junit")),
    "_hamcrest": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core")),
    "_bazel_test_runner": attr.label(default=Label("@bazel_tools//tools/jdk:TestRunner_deploy.jar"), allow_files=True),
}
_scala_junit_test_attrs.update(_launcher_template)
_scala_junit_test_attrs.update(_implicit_deps)
_scala_junit_test_attrs.update(_common_attrs)
_scala_junit_test_attrs.update(_junit_resolve_deps)
scala_junit_test = rule(
  implementation=_scala_junit_test_impl,
  attrs= _scala_junit_test_attrs,
  outputs= common_outputs,
  test=True,
  fragments = ["java"],
  toolchains = ['@io_bazel_rules_scala//scala:toolchain_type']
)

def scala_specs2_junit_test(name, **kwargs):
  scala_junit_test(
   name = name,
   deps = specs2_junit_dependencies() + kwargs.pop("deps",[]),
   suite_label = Label("//src/java/io/bazel/rulesscala/specs2:specs2_test_discovery"),
   suite_class = "io.bazel.rulesscala.specs2.Specs2DiscoveredTestSuite",
   **kwargs)
