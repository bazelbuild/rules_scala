load(
    "//scala:scala.bzl",
    "scala_library",
)

load(
    "//scala:scala_cross_version.bzl",
    "scala_mvn_artifact",
)

load("//scala/private:common.bzl", "write_manifest_file", "collect_srcjars",
     "collect_jars")

load("//scala/private:rule_impls.bzl", "compile_scala")

load("@io_bazel_rules_scala//thrift:thrift_info.bzl", "ThriftInfo")

load("@io_bazel_rules_scala//thrift:thrift.bzl", "merge_thrift_infos",
     "empty_thrift_info")

_jar_extension = ".jar"

def twitter_scrooge():
  native.maven_server(
      name = "twitter_scrooge_maven_server",
      url = "http://mirror.bazel.build/repo1.maven.org/maven2/",
  )

  native.maven_jar(
      name = "libthrift",
      artifact = "org.apache.thrift:libthrift:0.8.0",
      sha1 = "2203b4df04943f4d52c53b9608cef60c08786ef2",
      server = "twitter_scrooge_maven_server",
  )
  native.bind(
      name = 'io_bazel_rules_scala/dependency/thrift/libthrift',
      actual = '@libthrift//jar')

  native.maven_jar(
      name = "scrooge_core",
      artifact = scala_mvn_artifact("com.twitter:scrooge-core:4.6.0"),
      sha1 = "84b86c2e082aba6e0c780b3c76281703b891a2c8",
      server = "twitter_scrooge_maven_server",
  )
  native.bind(
      name = 'io_bazel_rules_scala/dependency/thrift/scrooge_core',
      actual = '@scrooge_core//jar')

  #scrooge-generator related dependencies
  native.maven_jar(
      name = "scrooge_generator",
      artifact = scala_mvn_artifact("com.twitter:scrooge-generator:4.6.0"),
      sha1 = "cacf72eedeb5309ca02b2d8325c587198ecaac82",
      server = "twitter_scrooge_maven_server",
  )
  native.bind(
      name = 'io_bazel_rules_scala/dependency/thrift/scrooge_generator',
      actual = '@scrooge_generator//jar')

  native.maven_jar(
      name = "util_core",
      artifact = scala_mvn_artifact("com.twitter:util-core:6.33.0"),
      sha1 = "bb49fa66a3ca9b7db8cd764d0b26ce498bbccc83",
      server = "twitter_scrooge_maven_server",
  )
  native.bind(
      name = 'io_bazel_rules_scala/dependency/thrift/util_core',
      actual = '@util_core//jar')

  native.maven_jar(
      name = "util_logging",
      artifact = scala_mvn_artifact("com.twitter:util-logging:6.33.0"),
      sha1 = "3d28e46f8ee3b7ad1b98a51b98089fc01c9755dd",
      server = "twitter_scrooge_maven_server",
  )
  native.bind(
      name = 'io_bazel_rules_scala/dependency/thrift/util_logging',
      actual = '@util_logging//jar')

def _colon_paths(data):
  return ':'.join([f.path for f in sorted(data)])

ScroogeAspectInfo = provider(fields = [
    "thrift_info",
    "src_jars",
    "output_files",
    "java_info",
])

ScroogeInfo = provider(fields = [
    "aspect_info",
])

ScroogeImport = provider(fields = [
    "java_info",
    "thrift_info",
])

def merge_scrooge_aspect_info(scrooges):
  return ScroogeAspectInfo(
      src_jars = depset(transitive = [s.src_jars for s in scrooges]),
      output_files = depset(transitive = [s.output_files for s in scrooges]),
      thrift_info = merge_thrift_infos([s.thrift_info for s in scrooges]),
      java_info = java_common.merge([s.java_info for s in scrooges]))

def _compile_to_scala(ctx, label, compile_thrifts, include_thrifts, jar_output):
  # bazel worker arguments cannot be empty so we pad to ensure non-empty
  # and drop it off on the other side
  # https://github.com/bazelbuild/bazel/issues/3329
  worker_arg_pad = "_"
  path_content = "\n".join([
      worker_arg_pad + _colon_paths(ps)
      for ps in [compile_thrifts, include_thrifts, [], []]
  ])
  worker_content = "{output}\n{paths}\n{flags}".format(
      output = jar_output.path,
      paths = path_content,
      flags = worker_arg_pad + ':'.join([
          # always add finagle option which is a no-op if there are no services
          # we could put "include_services" on thrift_info, if needed
          '--with-finagle',
      ]))

  argfile = ctx.actions.declare_file(
      "%s_worker_input" % label.name, sibling = jar_output)
  ctx.actions.write(output = argfile, content = worker_content)
  ctx.actions.run(
      executable = ctx.executable._pluck_scrooge_scala,
      inputs = compile_thrifts + include_thrifts + [argfile],
      outputs = [jar_output],
      mnemonic = "ScroogeRule",
      progress_message = "creating scrooge files %s" % ctx.label,
      execution_requirements = {"supports-workers": "1"},
      #  when we run with a worker, the `@argfile.path` is removed and passed
      #  line by line as arguments in the protobuf. In that case,
      #  the rest of the arguments are passed to the process that
      #  starts up and stays resident.

      # In either case (worker or not), they will be jvm flags which will
      # be correctly handled since the executable is a jvm app that will
      # consume the flags on startup.
      #arguments = ["--jvm_flag=%s" % flag for flag in ctx.attr.jvm_flags] +
      arguments = ["@" + argfile.path],
  )

def _compiled_jar_file(actions, scrooge_jar):
  scrooge_jar_name = scrooge_jar.basename
  # ends with .srcjar, so remove last 6 characters
  without_suffix = scrooge_jar_name[0:len(scrooge_jar_name) - 6]
  # this already ends with _scrooge because that is how scrooge_jar is named
  compiled_jar = without_suffix + "jar"
  return actions.declare_file(compiled_jar, sibling = scrooge_jar)

def _compile_scala(ctx, label, output, scrooge_jar, deps_java_info,
                   implicit_deps):

  manifest = ctx.actions.declare_file(
      label.name + "_MANIFEST.MF", sibling = scrooge_jar)
  write_manifest_file(ctx.actions, manifest, None)
  statsfile = ctx.actions.declare_file(
      label.name + "_scalac.statsfile", sibling = scrooge_jar)
  merged_deps = java_common.merge(deps_java_info + implicit_deps)

  # this only compiles scala, not the ijar, but we don't
  # want the ijar for generated code anyway: any change
  # in the thrift generally will change the interface and
  # method bodies
  compile_scala(
      ctx,
      label,
      output,
      manifest,
      statsfile,
      sources = [],
      cjars = merged_deps.transitive_compile_time_jars,
      all_srcjars = depset([scrooge_jar]),
      transitive_compile_jars = merged_deps.transitive_compile_time_jars,
      plugins = [],
      resource_strip_prefix = "",
      resources = [],
      resource_jars = [],
      labels = {},
      in_scalacopts = [],
      print_compile_time = False,
      expect_java_output = False,
      scalac_jvm_flags = [])

  return JavaInfo(
      source_jar = scrooge_jar,
      deps = deps_java_info + implicit_deps,
      runtime_deps = deps_java_info + implicit_deps,
      exports = deps_java_info + implicit_deps,
      output_jar = output,
      compile_jar = output)

def _empty_java_info(deps_java_info, implicit_deps):
  merged_deps = java_common.merge(deps_java_info + implicit_deps)
  return java_common.create_provider(
      use_ijar = False,
      compile_time_jars = depset(transitive = [merged_deps.compile_jars]),
      transitive_compile_time_jars = depset(
          transitive = [merged_deps.transitive_compile_time_jars]),
      transitive_runtime_jars = depset(
          transitive = [merged_deps.transitive_runtime_jars]))

####
# This is applied to the DAG of thrift_librarys reachable from a deps
# or a scrooge_scala_library. Each thrift_library will be one scrooge
# invocation assuming it has some sources.
def _scrooge_aspect_impl(target, ctx):
  if ScroogeImport in target:
    target_import = target[ScroogeImport]
    target_ti = target_import.thrift_info
    deps = [target_import.java_info]
    transitive_ti = target_ti
  else:
    target_ti = target[ThriftInfo]
    deps = [d[ScroogeAspectInfo].java_info for d in ctx.rule.attr.deps]
    transitive_ti = merge_thrift_infos(
        [d[ScroogeAspectInfo].thrift_info
         for d in ctx.rule.attr.deps] + [target_ti])

  # we sort so the inputs are always the same for caching
  compile_thrifts = sorted(target_ti.srcs.to_list())
  imps = [j[JavaInfo] for j in ctx.attr._implicit_compile_deps]
  if compile_thrifts:
    # we sort so the inputs are always the same for caching
    compile_thrift_map = {}
    for ct in compile_thrifts:
      compile_thrift_map[ct] = True
    include_thrifts = sorted([
        trans for trans in transitive_ti.transitive_srcs.to_list()
        if trans not in compile_thrift_map
    ])
    scrooge_file = ctx.actions.declare_file(
        target.label.name + "_scrooge.srcjar")
    _compile_to_scala(ctx, target.label, compile_thrifts, include_thrifts,
                      scrooge_file)

    src_jars = depset([scrooge_file])
    output = _compiled_jar_file(ctx.actions, scrooge_file)
    outs = depset([output])
    java_info = _compile_scala(ctx, target.label, output, scrooge_file, deps,
                               imps)

  else:
    # this target is only an aggregation target
    src_jars = depset()
    outs = depset()
    java_info = _empty_java_info(deps, imps)

  return [
      ScroogeAspectInfo(
          src_jars = src_jars,
          output_files = outs,
          thrift_info = transitive_ti,
          java_info = java_info)
  ]

scrooge_aspect = aspect(
    implementation = _scrooge_aspect_impl,
    attr_aspects = ['deps'],
    attrs = {
        "_pluck_scrooge_scala": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//src/scala/scripts:generator"),
            allow_files = True),
        "_scalac": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//src/java/io/bazel/rulesscala/scalac"),
            allow_files = True),
        "_implicit_compile_deps": attr.label_list(
            providers = [JavaInfo],
            default = [
                Label(
                    "//external:io_bazel_rules_scala/dependency/scala/scala_library"
                ),
                Label(
                    "//external:io_bazel_rules_scala/dependency/thrift/libthrift"
                ),
                Label(
                    "//external:io_bazel_rules_scala/dependency/thrift/scrooge_core"
                ),
            ]),
    },
    required_aspect_providers = [[ThriftInfo],
                                 [ScroogeImport]],
    toolchains = ['@io_bazel_rules_scala//scala:toolchain_type'],
)

def _scrooge_scala_library_impl(ctx):
  aspect_info = merge_scrooge_aspect_info(
      [dep[ScroogeAspectInfo] for dep in ctx.attr.deps])
  if ctx.attr.exports:
    exports = [exp[JavaInfo] for exp in ctx.attr.exports]
    all_java = java_common.merge(exports + [aspect_info.java_info])
  else:
    all_java = aspect_info.java_info

  return struct(
    scala = _create_scala_struct(ctx), # For IntelliJ support
    providers = [all_java, ScroogeInfo(aspect_info = aspect_info), DefaultInfo(files = aspect_info.output_files)]
  )

scrooge_scala_library = rule(
    implementation = _scrooge_scala_library_impl,
    attrs = {
        'deps': attr.label_list(aspects = [scrooge_aspect]),
        'exports': attr.label_list(providers = [JavaInfo]),
    },
    provides = [DefaultInfo, ScroogeInfo, JavaInfo],
)

def _create_scala_struct(ctx):
    """Create a scala provider in the shape expected by the IntelliJ bazel plugin."""
    output_jars = []

    if ctx.attr.exports:
      for exp in ctx.attr.exports:
        for j in exp[JavaInfo].outputs.jars:
          output_jars.append(struct(class_jar = j.class_jar, ijar = None, source_jar = None, source_jars = []))

    for dep in ctx.attr.deps:
      for j in dep[ScroogeAspectInfo].java_info.outputs.jars:
        output_jars.append(struct(class_jar = j.class_jar, ijar = None, source_jar = None, source_jars = []))

    return struct(
        outputs = struct(jars = output_jars)
    )

def _scrooge_scala_import_impl(ctx):
  scala_jars = depset(ctx.files.scala_jars)
  jars_ji = java_common.create_provider(
      use_ijar = False,
      compile_time_jars = scala_jars,
      transitive_compile_time_jars = scala_jars,
      transitive_runtime_jars = scala_jars)
  java_info = java_common.merge(
      [imp[JavaInfo] for imp in ctx.attr._implicit_compile_deps] + [jars_ji])
  # to make the thrift_info, we only put this in the
  # transitive part
  ti = ThriftInfo(
      srcs = depset(), transitive_srcs = depset(ctx.files.thrift_jars))
  return [java_info, ti, ScroogeImport(java_info = java_info, thrift_info = ti)]

# Allows you to consume thrifts and compiled jars from external repos
scrooge_scala_import = rule(
    implementation = _scrooge_scala_import_impl,
    attrs = {
        "thrift_jars": attr.label_list(allow_files = [".jar"]),
        "scala_jars": attr.label_list(allow_files = [".jar"]),
        "_implicit_compile_deps": attr.label_list(
            providers = [JavaInfo],
            default = [
                Label(
                    "//external:io_bazel_rules_scala/dependency/scala/scala_library"
                ),
                Label(
                    "//external:io_bazel_rules_scala/dependency/thrift/libthrift"
                ),
                Label(
                    "//external:io_bazel_rules_scala/dependency/thrift/scrooge_core"
                ),
            ]),
    },
    provides = [ThriftInfo, JavaInfo, ScroogeImport])
