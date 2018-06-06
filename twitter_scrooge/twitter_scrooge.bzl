load("//scala:scala.bzl",
     "scala_library",
)

load("@io_bazel_rules_scala//scala:providers.bzl",
     "ExtraInformation",
     "collect_transitive_extra_info",
)

load("//scala:scala_cross_version.bzl",
     "scala_mvn_artifact")

load("//scala/private:common.bzl",
  "write_manifest",
  "collect_jars"
)

load("//thrift:thrift.bzl", "ThriftInfo")

_jar_filetype = FileType([".jar"])

TwitterScroogeInfo = provider(
    fields = [
        "scala_srcjar",
        "owned_thrifts",
        "transitive_owned_thrifts",
        ])

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
  native.bind(name = 'io_bazel_rules_scala/dependency/thrift/libthrift', actual = '@libthrift//jar')

  native.maven_jar(
    name = "scrooge_core",
    artifact = scala_mvn_artifact("com.twitter:scrooge-core:4.6.0"),
    sha1 = "84b86c2e082aba6e0c780b3c76281703b891a2c8",
    server = "twitter_scrooge_maven_server",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/thrift/scrooge_core', actual = '@scrooge_core//jar')

  #scrooge-generator related dependencies
  native.maven_jar(
    name = "scrooge_generator",
    artifact = scala_mvn_artifact("com.twitter:scrooge-generator:4.6.0"),
    sha1 = "cacf72eedeb5309ca02b2d8325c587198ecaac82",
    server = "twitter_scrooge_maven_server",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/thrift/scrooge_generator', actual = '@scrooge_generator//jar')

  native.maven_jar(
    name = "util_core",
    artifact = scala_mvn_artifact("com.twitter:util-core:6.33.0"),
    sha1 = "bb49fa66a3ca9b7db8cd764d0b26ce498bbccc83",
    server = "twitter_scrooge_maven_server",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/thrift/util_core', actual = '@util_core//jar')

  native.maven_jar(
    name = "util_logging",
    artifact = scala_mvn_artifact("com.twitter:util-logging:6.33.0"),
    sha1 = "3d28e46f8ee3b7ad1b98a51b98089fc01c9755dd",
    server = "twitter_scrooge_maven_server",
  )
  native.bind(name = 'io_bazel_rules_scala/dependency/thrift/util_logging', actual = '@util_logging//jar')

def _collect_transitive_thrift_srcs(targets):
  r = []
  for target in targets:
    if ThriftInfo in target:
      r.append(target[ThriftInfo].transitive_srcs)
    elif hasattr(target, "transitive_srcs"):
      r.append(target.transitive_srcs)
  return depset(transitive = r)

def _collect_owned_thrift(targets):
  r = []
  for _target in targets:
    if hasattr(_target, "transitive_owned_thrifts"):
      r.append(_target.transitive_owned_thrifts)
    elif TwitterScroogeInfo in _target:
      r.append(_target[TwitterScroogeInfo].transitive_owned_thrifts)
  return depset(transitive = r)

def _collect_external_jars(targets):
  r = []
  for target in targets:
    if ThriftInfo in target:
      thrift = target[ThriftInfo]
      for jar in thrift.external_jars:
        r.extend(_jar_filetype.filter(jar.files))
      r.extend(_jar_filetype.filter(thrift.transitive_external_jars))
  return depset(r)

def _collect_immediate_thrifts(targets):
  srcs = []
  for target in targets:
    if ThriftInfo in target:
      srcs.append(target[ThriftInfo].srcs)
  return depset(srcs)

def _assert_set_is_subset(want, have):
  missing = []
  for e in want:
    if e not in have:
      missing.append(e)
  if len(missing) > 0:
    fail('scrooge_srcjar target must depend on scrooge_srcjar targets sufficient to ' +
         'cover the transitive graph of thrift files. Uncovered sources: ' + str(missing) + ' have: ' + str(have))

def _colon_paths(data):
  return ':'.join([f.path for f in data])

def _list_to_map(items):
  map_result = {}
  for item in items:
    map_result[item] = None
  return map_result

def _gen_scrooge_srcjar_impl(ctx):
  remote_jars = []
  for target in ctx.attr.remote_jars:
    remote_jars.append(_jar_filetype.filter(target.files))
  # deduplicate these
  remote_jars = depset(transitive = remote_jars).to_list()

  trans_extra_info = collect_transitive_extra_info(ctx.attr.deps)
  trans_extra_info_list = trans_extra_info.to_list()
  transitive_scrooges = []
  for t in trans_extra_info_list:
    if hasattr(t, "transitive_owned_thrifts"):
      transitive_scrooges.append(t)

  # These are the thrift sources whose generated code we will "own" as a target
  owned_thrifts = _collect_immediate_thrifts(ctx.attr.deps)

  # This is the set of sources which is covered by any scala_library
  # or scala_scrooge_gen targets that are depended on by this. This is
  # necessary as we only compile the sources we own, and rely on other
  # targets compiling the rest (for the benefit of caching and correctness).
  transitive_owned_thrifts = depset(
      transitive = [
          owned_thrifts,
          _collect_owned_thrift(ctx.attr.deps),
          _collect_owned_thrift(transitive_scrooges)])

  # These are the thrift sources in the dependency graph. They are necessary
  # to generate the code. We need to verify that all transitive thrift sources
  # are owned.
  transitive_thrift_srcs = _collect_transitive_thrift_srcs(ctx.attr.deps)

  only_transitive_thrift_srcs = []
  owned_thrifts_list = owned_thrifts.to_list()
  owned_thrifts_map = _list_to_map(owned_thrifts_list)
  for src in transitive_thrift_srcs.to_list():
    if src not in owned_thrifts_map:
      only_transitive_thrift_srcs.append(src)

  # We want to ensure that the thrift sources which we do not own (but need
  # in order to generate code) have targets which will compile them.
  _assert_set_is_subset(_list_to_map(transitive_thrift_srcs.to_list()), _list_to_map(transitive_owned_thrifts.to_list()))

  # These are JARs that are declared externally and only have Thrift files
  # in them.
  external_jars = _collect_external_jars(ctx.attr.deps).to_list()

  # bazel worker arguments cannot be empty so we pad to ensure non-empty
  # and drop it off on the other side
  # https://github.com/bazelbuild/bazel/issues/3329
  worker_arg_pad = "_"
  path_content = "\n".join([worker_arg_pad + _colon_paths(ps) for ps in [owned_thrifts_list, only_transitive_thrift_srcs, remote_jars, external_jars]])
  worker_content = "{output}\n{paths}\n{flags}".format(
          output = ctx.outputs.srcjar.path,
          paths = path_content,
          flags = worker_arg_pad + ':'.join([
              '--with-finagle' if ctx.attr.with_finagle else '',
          ]))

  argfile = ctx.actions.declare_file("%s_worker_input" % ctx.label.name, sibling = ctx.outputs.srcjar)
  ctx.actions.write(output=argfile, content=worker_content)
  ctx.actions.run(
    executable = ctx.executable._pluck_scrooge_scala,
    inputs = remote_jars +
        only_transitive_thrift_srcs +
        external_jars +
        owned_thrifts_list +
        [argfile],
    outputs = [ctx.outputs.srcjar],
    mnemonic="ScroogeRule",
    progress_message = "creating scrooge files %s" % ctx.label,
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

  # deps_jars = collect_jars(ctx.attr.deps)

  # scalaattr = struct(
  #     outputs = None,
  #     compile_jars = deps_jars.compile_jars,
  #     transitive_runtime_jars = deps_jars.transitive_runtime_jars,
  # )

  # srcjarsattr = struct(
  #   srcjar = ctx.outputs.srcjar,
  #   transitive_srcjars = transitive_srcjars,
  # )

  java_info = java_common.create_provider(
      ctx.actions,
      use_ijar = False,
      source_jars = [ctx.outputs.srcjar])

  scrooge_info = TwitterScroogeInfo(
      scala_srcjar = ctx.outputs.srcjar,
      owned_thrifts = owned_thrifts,
      transitive_owned_thrifts = transitive_owned_thrifts
  )
  extra_info = ExtraInformation(transitive_extra_information = depset([scrooge_info], transitive = [trans_extra_info]))
  return [extra_info, scrooge_info, java_info]

scrooge_scala_srcjar = rule(
    _gen_scrooge_srcjar_impl,
    attrs={
        "deps": attr.label_list(mandatory=True),
        #TODO we should think more about how we want to deal
        #     with these sorts of things... this basically
        #     is saying that we have a jar with a bunch
        #     of thrifts that we want to depend on. Seems like
        #     that should be a concern of thrift_library? we have
        #     it here through because we need to show that it is
        #     "covered," as well as needing the thrifts to
        #     do the code gen.
        "remote_jars": attr.label_list(),
        "jvm_flags": attr.string_list(),  # the jvm flags to use with the generator
        "with_finagle": attr.bool(default=False),
        "_pluck_scrooge_scala": attr.label(
          executable=True,
          cfg="host",
          default=Label("//src/scala/scripts:generator"),
          allow_files=True),
    },
    outputs={
      "srcjar": "lib%{name}.srcjar",
    },
)

def scrooge_scala_library(name, deps=[], remote_jars=[], jvm_flags=[], visibility=None, with_finagle=False):
    srcjar = name + '_srcjar'
    scrooge_scala_srcjar(
        name = srcjar,
        deps = deps,
        remote_jars = remote_jars,
        visibility = visibility,
        with_finagle = with_finagle,
    )

    # deps from macro invocation would come via srcjar
    # however, retained to make dependency analysis via aspects easier
    scala_library(
        name = name,
        deps = deps + remote_jars + [
            srcjar,
            "//external:io_bazel_rules_scala/dependency/thrift/libthrift",
            "//external:io_bazel_rules_scala/dependency/thrift/scrooge_core"
        ],
        exports = deps + remote_jars + [
            "//external:io_bazel_rules_scala/dependency/thrift/libthrift",
            "//external:io_bazel_rules_scala/dependency/thrift/scrooge_core",
        ],
        jvm_flags = jvm_flags,
        visibility = visibility,
    )
