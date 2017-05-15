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
_jar_filetype = FileType([".jar"])
_java_filetype = FileType([".java"])
_scala_filetype = FileType([".scala"])
_srcjar_filetype = FileType([".srcjar"])
# TODO is there a way to derive this from the above?
_scala_srcjar_filetype = FileType([".scala", ".srcjar", ".java"])

def _get_runfiles(target):
    runfiles = depset()
    runfiles += target.data_runfiles.files
    runfiles += target.default_runfiles.files
    return runfiles

def _get_all_runfiles(targets):
    runfiles = depset()
    for target in targets:
      runfiles += _get_runfiles(target)
    return runfiles

def _adjust_resources_path(path):
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


def _add_resources_cmd(ctx, dest):
    res_cmd = ""
    for f in ctx.files.resources:
        c_dir, res_path = _adjust_resources_path(f.path)
        target_path = res_path
        if res_path[0] != "/":
            target_path = "/" + res_path
        res_cmd += """
          mkdir -p $(dirname {out_dir}{target_path})
          cp {c_dir}{res_path} {out_dir}{target_path}
        """.format(
            out_dir=dest,
            res_path=res_path,
            target_path=target_path,
            c_dir=c_dir)
    return res_cmd


def _get_jar_path(paths):
    for p in paths:
        path = p.path
        if path.endswith("/binary_deploy.jar"):
            return path
    return None


def _build_nosrc_jar(ctx, buildijar):
    cp_resources = _add_resources_cmd(ctx, "{out}_tmp".format(
      out=ctx.outputs.jar.path)
    )
    ijar_cmd = ""
    if buildijar:
        ijar_cmd = "\ncp {out} {ijar_out}".format(
          out=ctx.outputs.jar.path,
          ijar_out=ctx.outputs.ijar.path)
    cmd = """
  rm -rf {out}_tmp
  set -e
  mkdir -p {out}_tmp
  # copy any resources
  {cp_resources}
  {java} -jar {jar} -m {manifest} {out}
  """ + ijar_cmd
    cmd = cmd.format(
        cp_resources=cp_resources,
        out=ctx.outputs.jar.path,
        manifest=ctx.outputs.manifest.path,
        java=ctx.executable._java.path,
        jar=_get_jar_path(ctx.files._jar))
    outs = [ctx.outputs.jar]
    if buildijar:
        outs.extend([ctx.outputs.ijar])

    # _jdk added manually since _java doesn't currently setup runfiles
    inputs = ctx.files.resources + ctx.files._jdk + [
        ctx.outputs.manifest,
        ctx.executable._jar,
        ctx.executable._java,
      ]

    ctx.action(
        inputs=inputs,
        outputs=outs,
        command=cmd,
        progress_message="scala %s" % ctx.label,
        arguments=[])


def _collect_plugin_paths(plugins):
    paths = set()
    for p in plugins:
        if hasattr(p, "path"):
            paths += [p.path]
        elif hasattr(p, "scala"):
            paths += [p.scala.outputs.jar.path]
        elif hasattr(p, "java"):
            paths += [j.class_jar.path for j in p.java.outputs.jars]
        # support http_file pointed at a jar. http_jar uses ijar,
        # which breaks scala macros
        elif hasattr(p, "files"):
            paths += [f.path for f in p.files]
    return paths


def _compile(ctx, _jars, dep_srcjars, buildijar):
    jars = _jars
    ijar_output_path = ""
    ijar_cmd_path = ""
    if buildijar:
        ijar_output_path = ctx.outputs.ijar.path
        ijar_cmd_path = ctx.executable._ijar.path

    java_srcs = _java_filetype.filter(ctx.files.srcs)
    sources = _scala_filetype.filter(ctx.files.srcs) + java_srcs
    srcjars = _srcjar_filetype.filter(ctx.files.srcs)
    all_srcjars = set(srcjars + list(dep_srcjars))
    # look for any plugins:
    plugins = _collect_plugin_paths(ctx.attr.plugins)
    plugin_arg = ",".join(list(plugins))

    compiler_classpath = ":".join([j.path for j in jars])

    scalac_args = """
Classpath: {cp}
EnableIjar: {enableijar}
Files: {files}
IjarCmdPath: {ijar_cmd_path}
IjarOutput: {ijar_out}
JarOutput: {out}
JavacOpts: {javac_opts}
JavacPath: {javac_path}
JavaFiles: {java_files}
JvmFlags: {jvm_flags}
Manifest: {manifest}
Plugins: {plugin_arg}
PrintCompileTime: {print_compile_time}
ResourceDests: {resource_dest}
ResourceJars: {resource_jars}
ResourceSrcs: {resource_src}
ResourceStripPrefix: {resource_strip_prefix}
ScalacOpts: {scala_opts}
SourceJars: {srcjars}
""".format(
        out=ctx.outputs.jar.path,
        manifest=ctx.outputs.manifest.path,
        scala_opts=",".join(ctx.attr.scalacopts),
        print_compile_time=ctx.attr.print_compile_time,
        plugin_arg=plugin_arg,
        cp=compiler_classpath,
        files=",".join([f.path for f in sources]),
        enableijar=buildijar,
        ijar_out=ijar_output_path,
        ijar_cmd_path=ijar_cmd_path,
        srcjars=",".join([f.path for f in all_srcjars]),
        javac_opts=" ".join(ctx.attr.javacopts),
        javac_path=ctx.executable._javac.path,
        java_files=",".join([f.path for f in java_srcs]),
        #  these are the flags passed to javac, which needs them prefixed by -J
        jvm_flags=",".join(["-J" + flag for flag in ctx.attr.jvm_flags]),
        resource_src=",".join([f.path for f in ctx.files.resources]),
        resource_dest=",".join(
          [_adjust_resources_path(f.path)[1] for f in ctx.files.resources]
          ),
        resource_strip_prefix=ctx.attr.resource_strip_prefix,
        resource_jars=",".join([f.path for f in ctx.files.resource_jars]),
        )
    argfile = ctx.new_file(
      ctx.outputs.jar,
      "%s_worker_input" % ctx.label.name
    )
    ctx.file_action(output=argfile, content=scalac_args)

    outs = [ctx.outputs.jar]
    if buildijar:
        outs.extend([ctx.outputs.ijar])
    # _jdk added manually since _java doesn't currently setup runfiles
    # _scalac, as a java_binary, should already have it in its runfiles; however,
    # adding does ensure _java not orphaned if _scalac ever was not a java_binary
    ins = (list(jars) +
           list(dep_srcjars) +
           list(srcjars) +
           list(sources) +
           ctx.files.srcs +
           ctx.files.plugins +
           ctx.files.resources +
           ctx.files.resource_jars +
           ctx.files._jdk +
           [ctx.outputs.manifest,
            ctx.executable._ijar,
            ctx.executable._java,
            ctx.executable._javac,
            argfile])
    ctx.action(
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

        arguments=["--jvm_flag=%s" % flag for flag in ctx.attr.jvm_flags] + ["@" + argfile.path],
      )


def _compile_or_empty(ctx, jars, srcjars, buildijar):
    # We assume that if a srcjar is present, it is not empty
    if len(ctx.files.srcs) + len(srcjars) == 0:
        _build_nosrc_jar(ctx, buildijar)
        #  no need to build ijar when empty
        return struct(ijar=ctx.outputs.jar, class_jar=ctx.outputs.jar)
    else:
        _compile(ctx, jars, srcjars, buildijar)
        ijar = None
        if buildijar:
            ijar = ctx.outputs.ijar
        else:
            #  macro code needs to be available at compile-time,
            #  so set ijar == jar
            ijar = ctx.outputs.jar
        return struct(ijar=ijar, class_jar=ctx.outputs.jar)

def _build_deployable(ctx, jars):
    # the _jar_bin program we call below expects one optional argument:
    # -m is the argument to pass a manifest to our jar creation code
    # the next argument is the path manifest itself
    # the manifest is set up by methods that call this function (see usages
    # of _build_deployable and note that they always first call write_manifest)
    # that is what creates the manifest content
    #
    # following the manifest argument and the manifest, the next argument is
    # the output path for the target jar
    #
    # finally all the rest of the arguments are jars to be flattened into one
    # fat jar
    args = ["-m", ctx.outputs.manifest.path, ctx.outputs.deploy_jar.path]
    args.extend([j.path for j in jars])
    ctx.action(
        inputs=list(jars) + [ctx.outputs.manifest],
        outputs=[ctx.outputs.deploy_jar],
        executable=ctx.executable._jar_bin,
        mnemonic="ScalaDeployJar",
        progress_message="scala deployable %s" % ctx.label,
        arguments=args)

def write_manifest(ctx):
    # TODO(bazel-team): I don't think this classpath is what you want
    manifest = "Class-Path: \n"
    if getattr(ctx.attr, "main_class", ""):
        manifest += "Main-Class: %s\n" % ctx.attr.main_class

    ctx.file_action(
        output=ctx.outputs.manifest,
        content=manifest)

def _write_launcher(ctx, rjars, main_class, jvm_flags, args, run_before_binary, run_after_binary):
    classpath = ':'.join(
      ["$JAVA_RUNFILES/{repo}/{spath}".format(
          repo = ctx.workspace_name, spath = f.short_path
      ) for f in rjars])

    location_expanded_jvm_flags = []
    for jvm_flag in jvm_flags:
        location_expanded_jvm_flags.append(ctx.expand_location(jvm_flag, ctx.attr.data))

    content = """#!/bin/bash

case "$0" in
/*) self="$0" ;;
*)  self="$PWD/$0" ;;
esac

if [[ -z "$JAVA_RUNFILES" ]]; then
  if [[ -e "${{self}}.runfiles" ]]; then
    export JAVA_RUNFILES="${{self}}.runfiles"
  fi
  if [[ -n "$JAVA_RUNFILES" ]]; then
    export TEST_SRCDIR=${{TEST_SRCDIR:-$JAVA_RUNFILES}}
  fi
fi

export CLASSPATH={classpath}
{run_before_binary}
$JAVA_RUNFILES/{repo}/{java} {jvm_flags} {main_class} {args} "$@"
BINARY_EXIT_CODE=$?
{run_after_binary}
exit $BINARY_EXIT_CODE
""".format(
        classpath = classpath,
        repo = ctx.workspace_name,
        java = ctx.executable._java.short_path,
        jvm_flags = " ".join(location_expanded_jvm_flags),
        main_class = main_class,
        args = args,
        run_before_binary = run_before_binary,
        run_after_binary = run_after_binary,
    )

    ctx.file_action(
        output = ctx.outputs.executable,
        content = content,
    )

def collect_srcjars(targets):
    srcjars = set()
    for target in targets:
        if hasattr(target, "srcjars"):
            srcjars += [target.srcjars.srcjar]
    return srcjars


def _collect_jars(targets):
    """Compute the runtime and compile-time dependencies from the given targets"""  # noqa
    compile_jars = set()
    runtime_jars = set()
    for target in targets:
        found = False
        if hasattr(target, "scala"):
            if hasattr(target.scala.outputs, "ijar"):
                compile_jars += [target.scala.outputs.ijar]
            compile_jars += target.scala.transitive_compile_exports
            runtime_jars += target.scala.transitive_runtime_deps
            runtime_jars += target.scala.transitive_runtime_exports
            found = True
        if hasattr(target, "java"):
            # see JavaSkylarkApiProvider.java,
            # this is just the compile-time deps
            # this should be improved in bazel 0.1.5 to get outputs.ijar
            # compile_jars += [output.ijar for output in target.java.outputs.jars]
            compile_jars += target.java.transitive_deps
            runtime_jars += target.java.transitive_runtime_deps
            found = True
        if not found:
            # support http_file pointed at a jar. http_jar uses ijar,
            # which breaks scala macros
            runtime_jars += target.files
            compile_jars += target.files

    return struct(compiletime = compile_jars, runtime = runtime_jars)

# Extract very common code out from dependency analysis into single place
# automatically adds dependency on scala-library and scala-reflect
# collects jars from deps, runtime jars from runtime_deps, and
def _collect_jars_from_common_ctx(ctx, extra_deps = [], extra_runtime_deps = []):
    # Get jars from deps
    auto_deps = [ctx.attr._scalalib, ctx.attr._scalareflect]
    deps_jars = _collect_jars(ctx.attr.deps + auto_deps + extra_deps)
    (cjars, rjars) = (deps_jars.compiletime, deps_jars.runtime)
    rjars += _collect_jars(ctx.attr.runtime_deps + extra_runtime_deps).runtime
    return struct(compiletime = cjars, runtime = rjars)

def _lib(ctx, non_macro_lib):
    # This will be used to pick up srcjars from non-scala library
    # targets (like thrift code generation)
    srcjars = collect_srcjars(ctx.attr.deps)
    jars = _collect_jars_from_common_ctx(ctx)
    (cjars, rjars) = (jars.compiletime, jars.runtime)

    write_manifest(ctx)
    outputs = _compile_or_empty(ctx, cjars, srcjars, non_macro_lib)

    rjars += [ctx.outputs.jar]

    _build_deployable(ctx, rjars)
    rule_outputs = struct(ijar=outputs.ijar, class_jar=outputs.class_jar, deploy_jar=ctx.outputs.deploy_jar)

    texp = _collect_jars(ctx.attr.exports)
    scalaattr = struct(outputs=rule_outputs,
                       transitive_runtime_deps=rjars,
                       transitive_compile_exports=texp.compiletime,
                       transitive_runtime_exports=texp.runtime
                       )

    # Note that rjars already transitive so don't really
    # need to use transitive_files with _get_all_runfiles
    runfiles = ctx.runfiles(
        files=list(rjars),
        collect_data=True)

    return struct(
        files=set([ctx.outputs.jar]),  # Here is the default output
        scala=scalaattr,
        runfiles=runfiles,
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
    if hasattr(target, 'extra_information'):
      r.extend(target.extra_information)
  return r

def _scala_library_impl(ctx):
  return _lib(ctx, True)

def _scala_macro_library_impl(ctx):
  return _lib(ctx, False)  # don't build the ijar for macros

# Common code shared by all scala binary implementations.
def _scala_binary_common(ctx, cjars, rjars):
  write_manifest(ctx)
  outputs = _compile_or_empty(ctx, cjars, [], False)  # no need to build an ijar for an executable
  _build_deployable(ctx, list(rjars))

  # _jdk added manually since _java doesn't currently setup runfiles
  runfiles = ctx.runfiles(
      files = list(rjars) + [ctx.outputs.executable] + ctx.files._jdk,
      transitive_files = _get_runfiles(ctx.attr._java),
      collect_data = True)

  rule_outputs = struct(
      ijar=outputs.class_jar,
      class_jar=outputs.class_jar,
      deploy_jar=ctx.outputs.deploy_jar,
  )
  scalaattr = struct(outputs = rule_outputs,
                     transitive_runtime_deps = rjars,
                     transitive_compile_exports = set(),
                     transitive_runtime_exports = set()
                     )
  return struct(
      files=set([ctx.outputs.executable]),
      scala = scalaattr,
      runfiles=runfiles)

def _scala_binary_impl(ctx):
  jars = _collect_jars_from_common_ctx(ctx)
  (cjars, rjars) = (jars.compiletime, jars.runtime)
  rjars += [ctx.outputs.jar]

  _write_launcher(
      ctx = ctx,
      rjars = rjars,
      main_class = ctx.attr.main_class,
      jvm_flags = ctx.attr.jvm_flags,
      args = "",
      run_before_binary = "",
      run_after_binary = "",
  )
  return _scala_binary_common(ctx, cjars, rjars)

def _scala_repl_impl(ctx):
  # need scala-compiler for MainGenericRunner below
  jars = _collect_jars_from_common_ctx(ctx, extra_runtime_deps = [ctx.attr._scalacompiler])
  (cjars, rjars) = (jars.compiletime, jars.runtime)
  rjars += [ctx.outputs.jar]

  args = " ".join(ctx.attr.scalacopts)
  _write_launcher(
      ctx = ctx,
      rjars = rjars,
      main_class = "scala.tools.nsc.MainGenericRunner",
      jvm_flags = ["-Dscala.usejavacp=true"] + ctx.attr.jvm_flags,
      args = args,
      run_before_binary = """
# save stty like in bin/scala
saved_stty=$(stty -g 2>/dev/null)
if [[ ! $? ]]; then
  saved_stty=""
fi
""",
      run_after_binary = """
if [[ "$saved_stty" != "" ]]; then
  stty $saved_stty
  saved_stty=""
fi
""",
  )

  return _scala_binary_common(ctx, cjars, rjars)

def _scala_test_impl(ctx):
    if len(ctx.attr.suites) != 0:
        print(
          "suites attribute is deprecated. All scalatest test suites are run"
        )
    jars = _collect_jars_from_common_ctx(ctx,
        extra_runtime_deps = [ctx.attr._scalatest_reporter],
    )
    (cjars, rjars) = (jars.compiletime, jars.runtime)
    # _scalatest is an http_jar, so its compile jar is run through ijar
    # however, contains macros, so need to handle separately
    scalatest_jars = _collect_jars([ctx.attr._scalatest]).runtime
    cjars += scalatest_jars
    rjars += scalatest_jars

    rjars += [ctx.outputs.jar]

    args = " ".join([
        "-R \"{path}\"".format(path=ctx.outputs.jar.short_path),
        "-oWDS",
        "-C io.bazel.rules.scala.JUnitXmlReporter ",
    ])
    # main_class almost has to be "org.scalatest.tools.Runner" due to args....
    _write_launcher(
        ctx = ctx,
        rjars = rjars,
        main_class = ctx.attr.main_class,
        jvm_flags = ctx.attr.jvm_flags,
        args = args,
        run_before_binary = "",
        run_after_binary = "",
    )
    return _scala_binary_common(ctx, cjars, rjars)

def _gen_test_suite_flags_based_on_prefixes_and_suffixes(ctx, archive):
    return struct(suite_class = "io.bazel.rulesscala.test_discovery.DiscoveredTestSuite",
    archiveFlag = "-Dbazel.discover.classes.archive.file.path=%s" % archive.short_path,
    prefixesFlag = "-Dbazel.discover.classes.prefixes=%s" % ",".join(ctx.attr.prefixes),
    suffixesFlag = "-Dbazel.discover.classes.suffixes=%s" % ",".join(ctx.attr.suffixes),
    printFlag = "-Dbazel.discover.classes.print.discovered=%s" % ctx.attr.print_discovered_classes)

def _scala_junit_test_impl(ctx):
    if (not(ctx.attr.prefixes) and not(ctx.attr.suffixes)):
      fail("Setting at least one of the attributes ('prefixes','suffixes') is required")
    jars = _collect_jars_from_common_ctx(ctx,
        extra_deps = [ctx.attr._junit, ctx.attr._hamcrest, ctx.attr._suite],
    )
    (cjars, rjars) = (jars.compiletime, jars.runtime)

    rjars += [ctx.outputs.jar]

    test_suite = _gen_test_suite_flags_based_on_prefixes_and_suffixes(ctx, ctx.outputs.jar)
    launcherJvmFlags = ["-ea", test_suite.archiveFlag, test_suite.prefixesFlag, test_suite.suffixesFlag, test_suite.printFlag]
    _write_launcher(
        ctx = ctx,
        rjars = rjars,
        main_class = "org.junit.runner.JUnitCore",
        jvm_flags = launcherJvmFlags + ctx.attr.jvm_flags,
        args = test_suite.suite_class,
        run_before_binary = "",
        run_after_binary = "",
    )

    return _scala_binary_common(ctx, cjars, rjars)


_implicit_deps = {
  "_ijar": attr.label(executable=True, cfg="host", default=Label("@bazel_tools//tools/jdk:ijar"), allow_files=True),
  "_scalac": attr.label(executable=True, cfg="host", default=Label("//src/java/io/bazel/rulesscala/scalac"), allow_files=True),
  "_scalalib": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scala/scala_library"), allow_files=True),
  "_scalacompiler": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scala/scala_compiler"), allow_files=True),
  "_scalareflect": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/scala/scala_reflect"), allow_files=True),
  "_java": attr.label(executable=True, cfg="host", default=Label("@bazel_tools//tools/jdk:java"), allow_files=True),
  "_javac": attr.label(executable=True, cfg="host", default=Label("@bazel_tools//tools/jdk:javac"), allow_files=True),
  "_jar": attr.label(executable=True, cfg="host", default=Label("//src/java/io/bazel/rulesscala/jar:binary_deploy.jar"), allow_files=True),
  "_jar_bin": attr.label(executable=True, cfg="host", default=Label("//src/java/io/bazel/rulesscala/jar:binary")),
  "_jdk": attr.label(default=Label("//tools/defaults:jdk"), allow_files=True),
}

# Common attributes reused across multiple rules.
_common_attrs = {
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
  "print_compile_time": attr.bool(default=False, mandatory=False),
}

scala_library = rule(
  implementation=_scala_library_impl,
  attrs={
      "main_class": attr.string(),
      "exports": attr.label_list(allow_files=False),
      } + _implicit_deps + _common_attrs,
  outputs={
      "jar": "%{name}.jar",
      "deploy_jar": "%{name}_deploy.jar",
      "ijar": "%{name}_ijar.jar",
      "manifest": "%{name}_MANIFEST.MF",
      },
)

scala_macro_library = rule(
  implementation=_scala_macro_library_impl,
  attrs={
      "main_class": attr.string(),
      "exports": attr.label_list(allow_files=False),
      } + _implicit_deps + _common_attrs,
  outputs={
      "jar": "%{name}.jar",
      "deploy_jar": "%{name}_deploy.jar",
      "manifest": "%{name}_MANIFEST.MF",
      },
)

scala_binary = rule(
  implementation=_scala_binary_impl,
  attrs={
      "main_class": attr.string(mandatory=True),
      } + _implicit_deps + _common_attrs,
  outputs={
      "jar": "%{name}.jar",
      "deploy_jar": "%{name}_deploy.jar",
      "manifest": "%{name}_MANIFEST.MF",
      },
  executable=True,
)

scala_test = rule(
  implementation=_scala_test_impl,
  attrs={
      "main_class": attr.string(default="org.scalatest.tools.Runner"),
      "suites": attr.string_list(),
      "_scalatest": attr.label(default=Label('//external:io_bazel_rules_scala/dependency/scalatest/scalatest'), allow_files=True),
      "_scalatest_reporter": attr.label(default=Label("//scala/support:test_reporter")),
      } + _implicit_deps + _common_attrs,
  outputs={
      "jar": "%{name}.jar",
      "deploy_jar": "%{name}_deploy.jar",
      "manifest": "%{name}_MANIFEST.MF",
      },
  executable=True,
  test=True,
)

scala_repl = rule(
  implementation=_scala_repl_impl,
  attrs= _implicit_deps + _common_attrs,
  outputs={
      "jar": "%{name}.jar",
      "deploy_jar": "%{name}_deploy.jar",
      "manifest": "%{name}_MANIFEST.MF",
  },
  executable=True,
)

def scala_version():
  """return the scala version for use in maven coordinates"""
  return "2.11"

def scala_mvn_artifact(artifact):
  gav = artifact.split(":")
  groupid = gav[0]
  artifactid = gav[1]
  version = gav[2]
  return "%s:%s_%s:%s" % (groupid, artifactid, scala_version(), version)

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
    url = "http://bazel-mirror.storage.googleapis.com/oss.sonatype.org/content/groups/public/org/scalatest/scalatest_2.11/2.2.6/scalatest_2.11-2.2.6.jar",
    sha256 = "f198967436a5e7a69cfd182902adcfbcb9f2e41b349e1a5c8881a2407f615962",
  )

  native.maven_server(
    name = "scalac_deps_maven_server",
    url = "http://bazel-mirror.storage.googleapis.com/repo1.maven.org/maven2/",
  )

  native.maven_jar(
    name = "scalac_rules_protobuf_java",
    artifact = "com.google.protobuf:protobuf-java:3.1.0",
    sha1 = "e13484d9da178399d32d2d27ee21a77cfb4b7873",
    server = "scalac_deps_maven_server",
  )

  native.bind(name = 'io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java', actual = '@scalac_rules_protobuf_java//jar')

  native.bind(name = 'io_bazel_rules_scala/dependency/scala/parser_combinators', actual = '@scala//:scala-parser-combinators')

  native.bind(name = 'io_bazel_rules_scala/dependency/scala/scala_compiler', actual = '@scala//:scala-compiler')

  native.bind(name = 'io_bazel_rules_scala/dependency/scala/scala_library', actual = '@scala//:scala-library')

  native.bind(name = 'io_bazel_rules_scala/dependency/scala/scala_reflect', actual = '@scala//:scala-reflect')

  native.bind(name = 'io_bazel_rules_scala/dependency/scala/scala_xml', actual = '@scala//:scala-xml')

  native.bind(name = 'io_bazel_rules_scala/dependency/scalatest/scalatest', actual = '@scalatest//jar')

def scala_export_to_java(name, exports, runtime_deps):
  jars = []
  for target in exports:
    jars.append("{}_deploy.jar".format(target))

  native.java_import(
    name = name,
    # these are the outputs of the scala_library targets
    jars = jars,
    runtime_deps = ["//external:io_bazel_rules_scala/dependency/scala/scala_library"] + runtime_deps
  )

def _sanitize_string_for_usage(s):
    res_array = []
    for c in s:
        if c.isalnum() or c == ".":
            res_array.append(c)
        else:
            res_array.append("_")
    return "".join(res_array)

# This auto-generates a test suite based on the passed set of targets
# we will add a root test_suite with the name of the passed name
def scala_test_suite(name, srcs = [], deps = [], runtime_deps = [], data = [], resources = [],
                     scalacopts = [], jvm_flags = [], visibility = None, size = None):
    ts = []
    for test_file in srcs:
        n = "%s_test_suite_%s" % (name, _sanitize_string_for_usage(test_file))
        scala_test(name = n, srcs = [test_file], deps = deps, runtime_deps = runtime_deps, resources=resources, scalacopts=scalacopts, jvm_flags=jvm_flags, visibility=visibility, size=size)
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

scala_junit_test = rule(
  implementation=_scala_junit_test_impl,
  attrs= _implicit_deps + _common_attrs + {
      "prefixes": attr.string_list(default=[]),
      "suffixes": attr.string_list(default=[]),
      "print_discovered_classes": attr.bool(default=False, mandatory=False),
      "_junit": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/junit/junit")),
      "_hamcrest": attr.label(default=Label("//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core")),
      "_suite": attr.label(default=Label("//src/java/io/bazel/rulesscala/test_discovery:test_discovery")),
      },
  outputs={
      "jar": "%{name}.jar",
      "deploy_jar": "%{name}_deploy.jar",
      "manifest": "%{name}_MANIFEST.MF",
      },
  test=True,
)

def scala_specs2_junit_test(name, **kwargs):
  scala_junit_test(
   name = name,
   deps = specs2_junit_dependencies() + kwargs.pop("deps",[]),
   **kwargs)
