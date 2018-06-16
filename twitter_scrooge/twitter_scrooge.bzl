load(
    "//scala:scala.bzl",
    "scala_library",
)

load(
    "//scala:scala_cross_version.bzl",
    "scala_mvn_artifact",
)

load("//scala/private:common.bzl", "write_manifest", "collect_srcjars",
     "collect_jars")

load("//thrift:thrift.bzl",
     "ThriftInfo",
     "merge_thrift_infos",
     "empty_thrift_info")

_jar_filetype = FileType([".jar"])

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

ScroogeAspectInfo = provider(
    fields = [
        "thrift_info",
        "src_jars",
        "java_info",
    ])

ScroogeInfo = provider(
    fields = [
      "aspect_info",
    ]
)

def merge_scrooge_aspect_info(scrooges):
  return ScroogeAspectInfo(
      src_jars = depset(transitive = [s.src_jars for s in scrooges]),
      thrift_info = merge_thrift_infos([s.thrift_info for s in scrooges]),
      java_info = java_common.merge([s.java_info for s in scrooges]))

def _compile_to_scala(ctx, label, compile_thrifts, include_thrifts, jar_output):
  # bazel worker arguments cannot be empty so we pad to ensure non-empty
  # and drop it off on the other side
  # https://github.com/bazelbuild/bazel/issues/3329
  worker_arg_pad = "_"
  path_content = "\n".join([
      worker_arg_pad + _colon_paths(ps) for ps in [
          compile_thrifts, include_thrifts, [], []
      ]
  ])
  worker_content = "{output}\n{paths}\n{flags}".format(
      output = jar_output.path,
      paths = path_content,
      flags = worker_arg_pad + ':'.join([
         # '--with-finagle' if ctx.attr.with_finagle else '',
         ''
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

####
# if we have a thrift target here, then we get all
# the srcjars of its dependencies and the thrifts
# we compute pass the deps as the extra thrifts,
# we then create a new srcjar for the current target
# we compute the transitive srcjars and transitive thriftjars
# return those in a provider.
#
# if we have another ScroogeSrc, we pass that through.
# finally, the scrooge_scala_library takes all the ScroogeSrcs
# and just calls the scala compiler only on the srcjars, but also
# returns the merged ScroogeSrc.
#
# not clear if the above is correct since we want to make sure
# we invoke scalac once on each thrift jar, so we may need to make
# sure to run scalac inside the aspect as well, otherwise we
# may call it over and over in diamond cases.
def _scrooge_aspect_impl(target, ctx):
  if ThriftInfo in target:
    # in this branch we need to generate the scrooge_src
    target_ti = target[ThriftInfo]
    # we sort so the inputs are always the same for caching
    compile_thrifts = sorted(target_ti.srcs.to_list())
    transitive_ti = merge_thrift_infos(
        [d[ScroogeAspectInfo].thrift_info for d in ctx.rule.attr.deps] + [target_ti]
    )
    # we sort so the inputs are always the same for caching
    compile_thrift_map = {}
    for ct in compile_thrifts:
      compile_thrift_map[ct] = True
    include_thrifts = sorted([trans for trans in transitive_ti.transitive_srcs.to_list() if trans not in compile_thrift_map])
    scrooge_file = ctx.actions.declare_file(target.label.name + "_scrooge.srcjar", sibling = sorted(target.files.to_list())[0])
    _compile_to_scala(ctx, target.label, compile_thrifts, include_thrifts, scrooge_file)

    deps_ji = java_common.merge([d[ScroogeAspectInfo].java_info for d in ctx.rule.attr.deps])
    # TODO
    # this function should be somewhere so we can compose scala compilation
    # java_info = compile_scala(ctx, [], [scrooge_file], deps_ji, srcjar_may_contain_java = False)
    java_info = deps_ji # this is wrong, but just to make things somewhat run

    return [ScroogeAspectInfo(src_jars = depset([scrooge_file]), thrift_info = transitive_ti, java_info = java_info)]
  elif ScroogeInfo in target:
    # in this branch we are just getting the already constructed aspect info
    return [target[ScroogeInfo].aspect_info]
  else:
    fail("expected scrooge_scala_library or thrift_library as a dep: " + str(dir(target)) + str(ctx.rule))

scrooge_aspect = aspect(
    implementation = _scrooge_aspect_impl,
    attr_aspects = ['deps'],
    attrs = {
        "_pluck_scrooge_scala": attr.label(
            executable = True,
            cfg = "host",
            default = Label("//src/scala/scripts:generator"),
            allow_files = True),
    },
    required_aspect_providers = [[ScroogeInfo], [ThriftInfo]],
)

def _scrooge_scala_library_impl(ctx):
  aspect_info = merge_scrooge_aspect_info([dep[ScroogeAspectInfo] for dep in ctx.attr.deps])
  return [ScroogeInfo(aspect_info = aspect_info), aspect_info.java_info]

scrooge_scala_library = rule(
    implementation = _scrooge_scala_library_impl,
    attrs = {
        'deps' : attr.label_list(aspects = [scrooge_aspect]),
        'remote_jars' : attr.label_list(),
        'jvm_flags' : attr.string_list(),
        'with_finagle': attr.bool(default = False),
    },
    provides = [ScroogeInfo],
)

