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


_scala_filetype = FileType([".scala"])

def _adjust_resources_path(path):
  dir_1, dir_2, rel_path = path.partition("resources")
  if rel_path:
    return dir_1 + dir_2, rel_path
  (dir_1,dir_2,rel_path) = path.partition("java")
  if rel_path:
    return dir_1 + dir_2, rel_path
  return "", path

def _build_nosrc_jar(ctx, buildijar):
  res_cmd = ""
  for f in ctx.files.resources:
    c_dir, res_path = _adjust_resources_path(f.path)
    change_dir = "-C " + c_dir if c_dir else ""
    res_cmd = "\n{jar} uf {out} " + change_dir + " " + res_path
  ijar_cmd = ""
  if buildijar:
    ijar_cmd = "\ncp {out} {ijar_out}".format(
      out=ctx.outputs.jar.path,
      ijar_out=ctx.outputs.ijar.path)
  cmd = """
set -e
# Make jar file deterministic by setting the timestamp of files
touch -t 198001010000 {manifest}
{jar} cmf {manifest} {out}
""" + ijar_cmd + res_cmd
  cmd = cmd.format(
      out=ctx.outputs.jar.path,
      manifest=ctx.outputs.manifest.path,
      jar=ctx.file._jar.path)
  outs = [ctx.outputs.jar]
  if buildijar:
    outs.extend([ctx.outputs.ijar])
  ctx.action(
      inputs=
          ctx.files.resources +
          ctx.files._jdk +
          [ctx.outputs.manifest, ctx.file._jar],
      outputs=outs,
      command=cmd,
      progress_message="scala %s" % ctx.label,
      arguments=[])

def _compile_scalac(ctx, jars):
  cmd = """
set -e
mkdir -p {out}_tmp
{scalac} {scala_opts} {jvm_flags} -classpath "{jars}" $@ -d {out}_tmp
# Make jar file deterministic by setting the timestamp of files
find {out}_tmp -exec touch -t 198001010000 {{}} \;
touch -t 198001010000 {manifest}
{jar} cmf {manifest} {out} -C {out}_tmp .
""" + _get_res_cmd(ctx)
  cmd = cmd.format(
      scalac=ctx.file._scalac.path,
      scala_opts=" ".join(ctx.attr.scalacopts),
      jvm_flags=" ".join(["-J" + flag for flag in ctx.attr.jvm_flags]),
      out=ctx.outputs.jar.path,
      manifest=ctx.outputs.manifest.path,
      jar=ctx.file._jar.path,
      jars=":".join([j.path for j in jars]),)

  ctx.action(
      inputs=list(jars) +
          ctx.files.srcs +
          ctx.files.resources +
          ctx.files._jdk +
          ctx.files._scalasdk +
          [ctx.outputs.manifest, ctx.file._jar, ctx.file._ijar],
      outputs=[ctx.outputs.jar],
      command=cmd,
      progress_message="scala %s" % ctx.label,
      arguments=[f.path for f in ctx.files.srcs])

def _compile_zinc(ctx, jars):
  worker = ctx.executable.worker

  tmp_out_dir = ctx.new_file(ctx.outputs.jar.path + "_tmp")

  flags = [
    "-fork-java",
    "-scala-compiler", ctx.file._scala_compiler_jar.path,
    "-scala-library", ctx.file._scala_library_jar.path,
    "-scala-extra", ctx.file._scala_reflect_jar.path,
    "-sbt-interface", ctx.file._sbt_interface_jar.path,
    "-compiler-interface", ctx.file._compiler_interface_jar.path,
    "-cp {jars}",
    "-d", tmp_out_dir.path,
  ]
  flags = " ".join(flags)
  flags = flags.format(
      out=ctx.outputs.jar.path,
      jars=":".join([j.path for j in jars]))
  work_unit_args = ctx.new_file(ctx.configuration.bin_dir, ctx.label.name + "_args")
  ctx.file_action(output = work_unit_args, content=flags)

  # Generate the "@"-file containing the command-line args for the unit of work.
  argfile = ctx.new_file(ctx.configuration.bin_dir, "worker_input")
  argfile_contents = "\n".join(["-argfile", work_unit_args.path] + [f.path for f in ctx.files.srcs])
  ctx.file_action(output=argfile, content=argfile_contents)

  # Classpath for the compiler/worker itself, these are not the compile time dependencies.
  classpath_jars = [
      ctx.file._compiler_interface_jar,
      ctx.file._incremental_compiler_jar,
      ctx.file._scala_compiler_jar,
      ctx.file._scala_library_jar,
      ctx.file._scala_reflect_jar,
      ctx.file._sbt_interface_jar,
      ctx.file._zinc,
      ctx.file._zinc_compiler_jar,
      ctx.file._nailgun_server_jar,
  ]
  compiler_classpath = ":".join([f.path for f in classpath_jars])

  ctx.action(
      inputs=list(jars) + ctx.files.srcs + [ctx.outputs.manifest, argfile, work_unit_args] + classpath_jars,
      outputs=[tmp_out_dir],
      executable=worker,
      progress_message="Zinc Worker: %s" % ctx.label.name,
      mnemonic="Scala",
      arguments=ctx.attr.worker_args + [compiler_classpath] + ["@" + argfile.path],
  )

  cmd = """
set -e
# Make jar file deterministic by setting the timestamp of files
find {tmp_out} | xargs touch -t 198001010000
touch -t 198001010000 {manifest}
jar cmf {manifest} {out} -C {tmp_out} .
""" + _get_res_cmd(ctx)
  cmd = cmd.format(
      tmp_out=tmp_out_dir.path,
      out=ctx.outputs.jar.path,
      manifest=ctx.outputs.manifest.path)

  ctx.action(
      inputs=[tmp_out_dir, ctx.outputs.manifest],
      outputs=[ctx.outputs.jar],
      command=cmd,
      progress_message="Building Jar: %s" % ctx.label)


def _get_res_cmd(ctx):
  res_cmd = ""
  for f in ctx.files.resources:
    c_dir, res_path = _adjust_resources_path(f.path)
    change_dir = "-C " + c_dir if c_dir else ""
    res_cmd = "\n{jar} uf {out} " + change_dir + " " + res_path
    res_cmd = res_cmd.format(
      out=ctx.outputs.jar.path,
      jar=ctx.file._jar.path,)
  return res_cmd

def _build_ijar(ctx):
  ijar_cmd = """
    set -e
    {ijar} {out} {ijar_out}
  """.format(
    ijar=ctx.file._ijar.path,
    out=ctx.outputs.jar.path,
    ijar_out=ctx.outputs.ijar.path)

  ctx.action(
    inputs=[ctx.outputs.jar, ctx.file._ijar],
    outputs=[ctx.outputs.ijar],
    command=ijar_cmd,
    progress_message="scala ijar %s" % ctx.label,)


def _compile(ctx, jars, buildijar, usezinc):
  if usezinc:
    _compile_zinc(ctx, jars)
  else:
    _compile_scalac(ctx, jars)

  if buildijar:
    _build_ijar(ctx)

def _compile_or_empty(ctx, jars, buildijar, usezinc):
  if len(ctx.files.srcs) == 0:
    _build_nosrc_jar(ctx, buildijar)
    #  no need to build ijar when empty
    return struct(ijar=ctx.outputs.jar, class_jar=ctx.outputs.jar)
  else:
    _compile(ctx, jars, buildijar, usezinc)
    ijar = None
    if buildijar:
      ijar = ctx.outputs.ijar
    else:
      #  macro code needs to be available at compile-time, so set ijar == jar
      ijar = ctx.outputs.jar
    return struct(ijar=ijar, class_jar=ctx.outputs.jar)

def _write_manifest(ctx):
  # TODO(bazel-team): I don't think this classpath is what you want
  manifest = "Class-Path: %s\n" % ctx.file._scalalib.path
  if getattr(ctx.attr, "main_class", ""):
    manifest += "Main-Class: %s\n" % ctx.attr.main_class

  ctx.file_action(
      output = ctx.outputs.manifest,
      content = manifest)


def _write_launcher(ctx, jars):
  content = """#!/bin/bash
cd $0.runfiles
{java} -cp {cp} {name} "$@"
"""
  content = content.format(
      java=ctx.file._java.path,
      name=ctx.attr.main_class,
      deploy_jar=ctx.outputs.jar.path,
      cp=":".join([j.short_path for j in jars]))
  ctx.file_action(
      output=ctx.outputs.executable,
      content=content)

def _write_test_launcher(ctx, jars):
  if len(ctx.attr.suites) != 0:
    print("suites attribute is deprecated. All scalatest test suites are run")

  content = """#!/bin/bash
cd $0.runfiles
{java} -cp {cp} {name} {args} "$@"
"""
  content = content.format(
      java=ctx.file._java.path,
      cp=":".join([j.short_path for j in jars]),
      name=ctx.attr.main_class,
      args="-R \"{path}\" -oWDF".format(path=ctx.outputs.jar.short_path))
  ctx.file_action(
      output=ctx.outputs.executable,
      content=content)

def _collect_jars(targets):
  """Compute the runtime and compile-time dependencies from the given targets"""
  compile_jars = set()  # not transitive
  runtime_jars = set()  # this is transitive
  for target in targets:
    found = False
    if hasattr(target, "scala"):
      compile_jars += [target.scala.outputs.ijar]
      compile_jars += target.scala.transitive_compile_exports
      runtime_jars += target.scala.transitive_runtime_deps
      runtime_jars += target.scala.transitive_runtime_exports
      found = True
    if hasattr(target, "java"):
      # see JavaSkylarkApiProvider.java, this is just the compile-time deps
      # this should be improved in bazel 0.1.5 to get outputs.ijar
      # compile_jars += [target.java.outputs.ijar]
      compile_jars += target.java.transitive_deps
      runtime_jars += target.java.transitive_runtime_deps
      found = True
    if not found:
      # support http_file pointed at a jar. http_jar uses ijar, which breaks scala macros
      runtime_jars += target.files
      compile_jars += target.files
  return struct(compiletime = compile_jars, runtime = runtime_jars)

def _lib(ctx, non_macro_lib, usezinc):
  jars = _collect_jars(ctx.attr.deps)
  (cjars, rjars) = (jars.compiletime, jars.runtime)
  _write_manifest(ctx)
  outputs = _compile_or_empty(ctx, cjars, non_macro_lib, usezinc)

  rjars += [ctx.outputs.jar]
  rjars += _collect_jars(ctx.attr.runtime_deps).runtime

  if not non_macro_lib:
    #  macros need the scala reflect jar
    cjars += [ctx.file._scalareflect]
    rjars += [ctx.file._scalareflect]

  texp = _collect_jars(ctx.attr.exports)
  scalaattr = struct(outputs = outputs,
                     transitive_runtime_deps = rjars,
                     transitive_compile_exports = texp.compiletime,
                     transitive_runtime_exports = texp.runtime
                     )
  runfiles = ctx.runfiles(
      files = list(rjars),
      collect_data = True)
  return struct(
      scala = scalaattr,
      runfiles=runfiles)

def _scala_library_impl(ctx):
  return _lib(ctx, True, usezinc = False)

def _scala_worker_impl(ctx):
  return _lib(ctx, True, usezinc = True)

def _scala_macro_library_impl(ctx):
  return _lib(ctx, False, usezinc = False)  # don't build the ijar for macros

# Common code shared by all scala binary implementations.
def _scala_binary_common(ctx, cjars, rjars):
  _write_manifest(ctx)
  _compile_or_empty(ctx, cjars, False, usezinc = False) # no need to build an ijar for an executable

  runfiles = ctx.runfiles(
      files = list(rjars) + [ctx.outputs.executable] + [ctx.file._java] + ctx.files._jdk,
      collect_data = True)
  return struct(
      files=set([ctx.outputs.executable]),
      runfiles=runfiles)

def _scala_binary_impl(ctx):
  jars = _collect_jars(ctx.attr.deps)
  (cjars, rjars) = (jars.compiletime, jars.runtime)
  cjars += [ctx.file._scalareflect]
  rjars += [ctx.outputs.jar, ctx.file._scalalib, ctx.file._scalareflect]
  rjars += _collect_jars(ctx.attr.runtime_deps).runtime
  _write_launcher(ctx, rjars)
  return _scala_binary_common(ctx, cjars, rjars)

def _scala_test_impl(ctx):
  jars = _collect_jars(ctx.attr.deps)
  (cjars, rjars) = (jars.compiletime, jars.runtime)
  cjars += [ctx.file._scalareflect, ctx.file._scalatest, ctx.file._scalaxml]
  rjars += [ctx.outputs.jar, ctx.file._scalalib, ctx.file._scalareflect, ctx.file._scalatest, ctx.file._scalaxml]
  rjars += _collect_jars(ctx.attr.runtime_deps).runtime
  _write_test_launcher(ctx, rjars)
  return _scala_binary_common(ctx, cjars, rjars)

_implicit_deps = {
  "_ijar": attr.label(executable=True, default=Label("//tools/defaults:ijar"), single_file=True, allow_files=True),
  "_scalac": attr.label(executable=True, default=Label("@scala//:bin/scalac"), single_file=True, allow_files=True),
  "_scalalib": attr.label(default=Label("@scala//:lib/scala-library.jar"), single_file=True, allow_files=True),
  # "_scalaxml": attr.label(default=Label("@scala//:lib/scala-xml_2.11-1.0.4.jar"), single_file=True, allow_files=True),
  "_scalaxml": attr.label(default=Label("@scala//:lib/scala-library.jar"), single_file=True, allow_files=True),
  "_scalasdk": attr.label(default=Label("@scala//:sdk"), allow_files=True),
  "_scalareflect": attr.label(default=Label("@scala//:lib/scala-reflect.jar"), single_file=True, allow_files=True),
  "_jar": attr.label(executable=True, default=Label("@bazel_tools//tools/jdk:jar"), single_file=True, allow_files=True),
  "_jdk": attr.label(default=Label("//tools/defaults:jdk"), allow_files=True),
}

# Common attributes reused across multiple rules.
_common_attrs = {
  "srcs": attr.label_list(
      allow_files=_scala_filetype),
  "deps": attr.label_list(),
  "runtime_deps": attr.label_list(),
  "data": attr.label_list(allow_files=True, cfg=DATA_CFG),
  "resources": attr.label_list(allow_files=True),
  "scalacopts":attr.string_list(),
  "jvm_flags": attr.string_list(),
}

_zinc_compile_attrs = {
  "_zinc": attr.label(
      default=Label("@zinc//file"),
      executable=True,
      single_file=True,
      allow_files=True),
  "_zinc_compiler_jar": attr.label(
      default=Label("@zinc_0_3_10_SNAPSHOT_jar//jar"),
      single_file=True,
      allow_files=True),
  "_scala_compiler_jar": attr.label(
      default=Label("@scala_compiler_jar//jar"),
      single_file=True,
      allow_files=True),
  "_incremental_compiler_jar": attr.label(
      default=Label("@incremental_compiler_0_13_9_jar//jar"),
      single_file=True,
      allow_files=True),
  "_scala_library_jar": attr.label(
      default=Label("@scala_library_jar//jar"),
      single_file=True,
      allow_files=True),
  "_scala_reflect_jar": attr.label(
      default=Label("@scala_reflect_jar//jar"),
      single_file=True,
      allow_files=True),
  "_sbt_interface_jar": attr.label(
      default=Label("@sbt_interface_0_13_9_jar//jar"),
      single_file=True,
      allow_files=True),
  "_compiler_interface_jar": attr.label(
      default=Label("@compiler_interface_0_13_9_sources_jar//jar"),
      single_file=True,
      allow_files=True),
  "_nailgun_server_jar": attr.label(
      default=Label("@nailgun_server_0_9_1_jar//jar"),
      single_file=True,
      allow_files=True),

}

scala_worker = rule(
  implementation=_scala_worker_impl,
  attrs={
      "main_class": attr.string(),
      "exports": attr.label_list(allow_files=False),
      # Worker Args
      "worker": attr.label(
          cfg=HOST_CFG,
          default=Label("@io_bazel_rules_scala//scala:scala-worker"),
          allow_files=True,
          executable=True),
      "worker_args": attr.string_list(),
      } + _implicit_deps + _common_attrs + _zinc_compile_attrs,
  outputs={
      "jar": "%{name}_deploy.jar",
      "ijar": "%{name}_ijar.jar",
      "manifest": "%{name}_MANIFEST.MF",
      },
)

scala_library = rule(
  implementation=_scala_library_impl,
  attrs={
      "main_class": attr.string(),
      "exports": attr.label_list(allow_files=False),
      } + _implicit_deps + _common_attrs,
  outputs={
      "jar": "%{name}_deploy.jar",
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
      "jar": "%{name}_deploy.jar",
      "manifest": "%{name}_MANIFEST.MF",
      },
)

scala_binary = rule(
  implementation=_scala_binary_impl,
  attrs={
      "main_class": attr.string(mandatory=True),
      "_java": attr.label(executable=True, default=Label("@bazel_tools//tools/jdk:java"), single_file=True, allow_files=True),
      } + _implicit_deps + _common_attrs,
  outputs={
      "jar": "%{name}_deploy.jar",
      "manifest": "%{name}_MANIFEST.MF",
      },
  executable=True,
)

scala_test = rule(
  implementation=_scala_test_impl,
  attrs={
      "main_class": attr.string(default="org.scalatest.tools.Runner"),
      "suites": attr.string_list(),
      "_scalatest": attr.label(executable=True, default=Label("@scalatest//file"), single_file=True, allow_files=True),
      "_java": attr.label(executable=True, default=Label("@bazel_tools//tools/jdk:java"), single_file=True, allow_files=True),
      } + _implicit_deps + _common_attrs,
  outputs={
      "jar": "%{name}_deploy.jar",
      "manifest": "%{name}_MANIFEST.MF",
      },
  executable=True,
  test=True,
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
exports_files([
  "bin/scala",
  "bin/scalac",
  "bin/scaladoc",
  "lib/akka-actor_2.11-2.3.10.jar",
  "lib/config-1.2.1.jar",
  "lib/jline-2.12.1.jar",
  "lib/scala-actors-2.11.0.jar",
  "lib/scala-actors-migration_2.11-1.1.0.jar",
  "lib/scala-compiler.jar",
  "lib/scala-continuations-library_2.11-1.0.2.jar",
  "lib/scala-continuations-plugin_2.11.7-1.0.2.jar",
  "lib/scala-library.jar",
  "lib/scala-parser-combinators_2.11-1.0.4.jar",
  "lib/scala-reflect.jar",
  "lib/scala-swing_2.11-1.0.2.jar",
  "lib/scala-xml_2.11-1.0.4.jar",
  "lib/scalap-2.11.7.jar",
])

filegroup(
    name = "sdk",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""

SCALA_2_10_BUILD_FILE = """
# scala.BUILD
exports_files([
  "bin/scala",
  "bin/scalac",
  "bin/scaladoc",
  "lib/akka-actors.jar",
  "lib/jline.jar",
  "lib/scala-actors-migration.jar",
  "lib/scala-actors.jar",
  "lib/scala-compiler.jar",
  "lib/scala-library.jar",
  "lib/scala-reflect.jar",
  "lib/scala-swing.jar",
  "lib/scalap.jar",
  "lib/typesafe-config.jar",
])

filegroup(
    name = "sdk",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)
"""

def scala_repositories():
  native.new_http_archive(
    name = "scala",
    strip_prefix = "scala-2.11.7",
    sha256 = "ffe4196f13ee98a66cf54baffb0940d29432b2bd820bd0781a8316eec22926d0",
    url = "https://downloads.typesafe.com/scala/2.11.7/scala-2.11.7.tgz",
    build_file_content = SCALA_BUILD_FILE,
  )
  native.http_file(
    name = "scalatest",
    url = "https://oss.sonatype.org/content/groups/public/org/scalatest/scalatest_2.11/2.2.6/scalatest_2.11-2.2.6.jar",
    sha256 = "f198967436a5e7a69cfd182902adcfbcb9f2e41b349e1a5c8881a2407f615962",
  )

def scala_2_10_repositories():
  native.new_http_archive(
    name = "scala",
    strip_prefix = "scala-2.10.6",
    sha256 = "54adf583dae6734d66328cafa26d9fa03b8c4cf607e27b9f3915f96e9bcd2d67",
    url = "https://downloads.lightbend.com/scala/2.10.6/scala-2.10.6.tgz",
    build_file_content = SCALA_2_10_BUILD_FILE,
  )

def zinc_repositories():
  native.http_file(
    name = "zinc",
    url = "https://databricks-mvn.s3.amazonaws.com/binaries/zinc/12-29-15/zinc?AWSAccessKeyId=AKIAJ6V3VSHTA5RSYEQA&Expires=1482970631&Signature=tAP2QKWEnte6v3DpRFtAxGNkUps%3D",
    sha256 = "255cbd2acb9e78ac30d20d3b57ba6fc4a38476b4eaa74173ba28c2839b4549df"
  )

  native.http_jar(
    name = "scala_compiler_jar",
    url = "https://databricks-mvn.s3.amazonaws.com/binaries/zinc/12-29-15/scala-compiler.jar?AWSAccessKeyId=AKIAJ6V3VSHTA5RSYEQA&Expires=1482962357&Signature=zDYAnLusbKWFFyhI3jokN%2FxissM%3D",
    sha256 = "7ceaacf9b279b0e53c49234709623f55f6ce61613f14183a817e91e870da6bc8"
  )

  native.http_jar(
    name = "incremental_compiler_0_13_9_jar",
    url = "https://databricks-mvn.s3.amazonaws.com/binaries/zinc/12-29-15/incremental-compiler-0.13.9.jar?AWSAccessKeyId=AKIAJ6V3VSHTA5RSYEQA&Expires=1482971670&Signature=usTDvNkRldp8FSFys%2Fm0zKy0aHg%3D",
    sha256 = "ddfbc88b9dd629118cad135ec32ec6cd1bc9969ca406cb780529a8cb037e1134"
  )

  native.http_jar(
    name = "scala_library_jar",
    url = "https://databricks-mvn.s3.amazonaws.com/binaries/zinc/12-29-15/scala-library.jar?AWSAccessKeyId=AKIAJ6V3VSHTA5RSYEQA&Expires=1482962357&Signature=fS5ZliC81RaOCArtLERGLOaCS2U%3D",
    sha256 = "2aa6d7e5bb277c4072ac04433b9626aab586a313a41a57e192ea2acf430cdc29"
  )

  native.http_jar(
    name = "sbt_interface_0_13_9_jar",
    url = "https://databricks-mvn.s3.amazonaws.com/binaries/zinc/12-29-15/sbt-interface-0.13.9.jar?AWSAccessKeyId=AKIAJ6V3VSHTA5RSYEQA&Expires=1482962357&Signature=uu9taX3NAXzcieiTgcjFSOKqBVM%3D",
    sha256 = "8004c0089728819896d678b3056b0ad0308e9760cb584b3cfc8eabde88f4e2bf"
  )

  native.http_jar(
    name = "compiler_interface_0_13_9_sources_jar",
    url = "https://databricks-mvn.s3.amazonaws.com/binaries/zinc/12-29-15/compiler-interface-0.13.9-sources.jar?AWSAccessKeyId=AKIAJ6V3VSHTA5RSYEQA&Expires=1482962357&Signature=bdNIS9%2BhpySfYIa7V9%2ByceDUClA%3D",
    sha256 = "d124212ca6d83abe7ef4a275f545a2ac1d3fc8a43ac49d5e2a40054783062127"
  )

  native.http_jar(
    name = "scala_reflect_jar",
    url = "https://databricks-mvn.s3.amazonaws.com/binaries/zinc/12-29-15/scala-reflect.jar?AWSAccessKeyId=AKIAJ6V3VSHTA5RSYEQA&Expires=1482962357&Signature=btywJi2tZAudjoCVlMyjagDbQ2o%3D",
    sha256 = "ad9b8ec8f7cb6a1d68d3b50a5d6cc61143b783f85523122871d98bac20dd48e3"
  )

  native.http_jar(
    name = "zinc_0_3_10_SNAPSHOT_jar",
    url = "https://databricks-mvn.s3.amazonaws.com/binaries/zinc/12-29-15/zinc-0.3.10-SNAPSHOT.jar?AWSAccessKeyId=AKIAJ6V3VSHTA5RSYEQA&Expires=1482968757&Signature=5mojfgtEVjsYUgoVWX54QSiUIu8%3D",
    sha256 = "1db98ace1e69a7b7f757f7726e494816583ed44ca46ccd3ed11563772dacb915"
  )

  native.http_jar(
    name = "nailgun_server_0_9_1_jar",
    url = "http://central.maven.org/maven2/com/martiansoftware/nailgun-server/0.9.1/nailgun-server-0.9.1.jar",
    sha256 = "4518faa6bf4bd26fccdc4d85e1625dc679381a08d56872d8ad12151dda9cef25"
  )

