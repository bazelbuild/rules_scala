_jar_filetype = FileType([".jar"])

load("//scala:scala.bzl",
  "scala_mvn_artifact",
  "scala_library",
  "write_manifest",
  "collect_srcjars")

def twitter_scrooge():
  native.maven_server(
    name = "twitter_scrooge_maven_server",
    url = "http://bazel-mirror.storage.googleapis.com/repo1.maven.org/maven2/",
  )

  native.maven_jar(
    name = "libthrift",
    artifact = "org.apache.thrift:libthrift:0.8.0",
    sha1 = "2203b4df04943f4d52c53b9608cef60c08786ef2",
    server = "twitter_scrooge_maven_server",
  )
  native.maven_jar(
    name = "scrooge_core",
    artifact = scala_mvn_artifact("com.twitter:scrooge-core:4.6.0"),
    sha1 = "84b86c2e082aba6e0c780b3c76281703b891a2c8",
    server = "twitter_scrooge_maven_server",
  )

  #scrooge-generator related dependencies
  native.maven_jar(
    name = "scrooge_generator",
    artifact = scala_mvn_artifact("com.twitter:scrooge-generator:4.6.0"),
    sha1 = "cacf72eedeb5309ca02b2d8325c587198ecaac82",
    server = "twitter_scrooge_maven_server",
  )
  native.maven_jar(
    name = "util_core",
    artifact = scala_mvn_artifact("com.twitter:util-core:6.33.0"),
    sha1 = "bb49fa66a3ca9b7db8cd764d0b26ce498bbccc83",
    server = "twitter_scrooge_maven_server",
  )
  native.maven_jar(
    name = "util_logging",
    artifact = scala_mvn_artifact("com.twitter:util-logging:6.33.0"),
    sha1 = "3d28e46f8ee3b7ad1b98a51b98089fc01c9755dd",
    server = "twitter_scrooge_maven_server",
  )

def _collect_transitive_srcs(targets):
  r = set()
  for target in targets:
    if hasattr(target, "thrift"):
      r += target.thrift.transitive_srcs
  return r

def _collect_owned_srcs(targets):
  r = set()
  for _target in targets:
    if hasattr(_target, "extra_information"):
      for target in _target.extra_information:
        if hasattr(target, "scrooge_srcjar"):
          r += target.scrooge_srcjar.transitive_owned_srcs
  return r

def collect_extra_srcjars(targets):
  srcjars = set()
  for target in targets:
    if hasattr(target, "extra_information"):
      for _target in target.extra_information:
        srcjars += [_target.srcjars.srcjar]
        srcjars += _target.srcjars.transitive_srcjars
  return srcjars

def _collect_immediate_srcs(targets):
  r = set()
  for target in targets:
    if hasattr(target, "thrift"):
      r += [target.thrift.srcs]
  return r

def _assert_set_is_subset(left, right):
  missing = set()
  for l in left:
    if l not in right:
      missing += [l]
  if len(missing) > 0:
    fail('scrooge_srcjar target must depend on scrooge_srcjar targets sufficient to ' +
         'cover the transitive graph of thrift files. Uncovered sources: ' + str(missing))

def _path_newline(data):
  return '\n'.join([f.path for f in data])

def _gen_scrooge_srcjar_impl(ctx):
  remote_jars = set()
  for target in ctx.attr.remote_jars:
    remote_jars += _jar_filetype.filter(target.files)

  # These are the thrift sources whose generated code we will "own" as a target
  immediate_thrift_srcs = _collect_immediate_srcs(ctx.attr.deps)

  # This is the set of sources which is covered by any scala_library
  # or scala_scrooge_gen targets that are depended on by this. This is
  # necessary as we only compile the sources we own, and rely on other
  # targets compiling the rest (for the benefit of caching and correctness).
  transitive_owned_srcs = _collect_owned_srcs(ctx.attr.deps)

  # These are the thrift sources in the dependency graph. They are necessary
  # to generate the code, but are not "owned" by this target and will not
  # be in the resultant source jar

  transitive_thrift_srcs = transitive_owned_srcs + _collect_transitive_srcs(ctx.attr.deps)

  only_transitive_thrift_srcs = set()
  for src in transitive_thrift_srcs:
    if src not in immediate_thrift_srcs:
      only_transitive_thrift_srcs += [src]

  # We want to ensure that the thrift sources which we do not own (but need
  # in order to generate code) have targets which will compile them.
  _assert_set_is_subset(only_transitive_thrift_srcs, transitive_owned_srcs)

  remote_jars_file = ctx.new_file(ctx.outputs.srcjar, ctx.outputs.srcjar.short_path + "_remote_jars")
  ctx.file_action(output=remote_jars_file, content=_path_newline(remote_jars))

  only_transitive_thrift_srcs_file = ctx.new_file(ctx.outputs.srcjar, ctx.outputs.srcjar.short_path + "_only_transitive_thrift_srcs")
  ctx.file_action(output = only_transitive_thrift_srcs_file, content = _path_newline(only_transitive_thrift_srcs))

  immediate_thrift_srcs_file = ctx.new_file(ctx.outputs.srcjar, ctx.outputs.srcjar.short_path + "_immediate_thrift_srcs")
  ctx.file_action(output = immediate_thrift_srcs_file, content = _path_newline(immediate_thrift_srcs))

  ctx.action(
    executable = ctx.executable._pluck_scrooge_scala,
    inputs = list(remote_jars) +
        list(only_transitive_thrift_srcs) +
        list(immediate_thrift_srcs) +
        [remote_jars_file,
         only_transitive_thrift_srcs_file,
         immediate_thrift_srcs_file],
    outputs = [ctx.outputs.srcjar],
    arguments = [
      only_transitive_thrift_srcs_file.path,
      immediate_thrift_srcs_file.path,
      ctx.outputs.srcjar.path,
      remote_jars_file.path,
    ],
    progress_message = "creating scrooge files %s" % ctx.label,
  )

  jars = _collect_scalaattr(ctx.attr.deps)

  scalaattr = struct(outputs = None,
                     transitive_runtime_deps = jars.transitive_runtime_deps,
                     transitive_compile_exports = jars.transitive_compile_exports,
                     transitive_runtime_exports = jars.transitive_runtime_exports,
                     )

  transitive_srcjars = collect_srcjars(ctx.attr.deps) + collect_extra_srcjars(ctx.attr.deps)

  srcjarsattr = struct(
    srcjar = ctx.outputs.srcjar,
    transitive_srcjars = transitive_srcjars,
  )

  return struct(
    scala = scalaattr,
    srcjars=srcjarsattr,
    extra_information=[struct(
      srcjars=srcjarsattr,
      scrooge_srcjar=struct(transitive_owned_srcs = transitive_owned_srcs + immediate_thrift_srcs),
    )],
  )

def _collect_scalaattr(targets):
  transitive_runtime_deps = set()
  transitive_compile_exports = set()
  transitive_runtime_exports = set()
  for target in targets:
    if hasattr(target, "scala"):
      transitive_runtime_deps += target.scala.transitive_runtime_deps
      transitive_compile_exports += target.scala.transitive_compile_exports
      if hasattr(target.scala.outputs, "ijar"):
        transitive_compile_exports += [target.scala.outputs.ijar]
      transitive_runtime_exports += target.scala.transitive_runtime_exports

  return struct(
    transitive_runtime_deps = transitive_runtime_deps,
    transitive_compile_exports = transitive_compile_exports,
    transitive_runtime_exports = transitive_runtime_exports,
  )

scrooge_scala_srcjar = rule(
    _gen_scrooge_srcjar_impl,
    attrs={
        "deps": attr.label_list(mandatory=True),
        #TODO we should think more about how we want to deal
        #     with these sorts of things... this basically
        #     is saying that we have a jar with a bunch
        #     of thrifts that we want to depend on. Seems like
        #     that should be a concern of thrift_library? we have
        #     it here through becuase we need to show that it is
        #     "covered," as well as needing the thrifts to
        #     do the code gen.
        "remote_jars": attr.label_list(),
        "_pluck_scrooge_scala": attr.label(
          executable=True,
          default=Label("//src/scala/scripts:generator"),
          allow_files=True),
    },
    outputs={
      "srcjar": "lib%{name}.srcjar",
    },
)

def scrooge_scala_library(name, deps=[], remote_jars=[], jvm_flags=[], visibility=None):
    srcjar = name + '_srcjar'
    scrooge_scala_srcjar(
        name = srcjar,
        deps = deps,
        remote_jars = remote_jars,
        visibility = visibility,
    )

    scala_library(
        name = name,
        deps = deps + remote_jars + [
            srcjar,
            "@libthrift//jar",
            "@scrooge_core//jar"
        ],
        exports = deps + remote_jars + [
            "@libthrift//jar",
            "@scrooge_core//jar",
        ],
        jvm_flags = jvm_flags,
        visibility = visibility,
    )
