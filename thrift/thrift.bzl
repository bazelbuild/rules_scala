"""Rules for organizing thrift files."""

_thrift_filetype = FileType([".thrift"])

def _common_prefix(strings):
  pref = None
  for s in strings:
    if pref == None:
      pref = s
    elif s.startswith(pref):
      pass
    else:
      tmp_pref = pref
      for end in range(0, len(pref) + 1):
        test = pref[0:end]
        if s.startswith(test):
          tmp_pref = test
      pref = tmp_pref
  return pref

def _thrift_library_impl(ctx):
  prefix = ctx.attr.absolute_prefix
  src_paths = [f.path for f in ctx.files.srcs]
  if len(src_paths) <= 0:
    fail("we require at least one thrift file in a target")

  jarcmd = "{jar} cMf {out} -C {out}_tmp ."
  if prefix != '':
    common_prefix = _common_prefix(src_paths)
    pos = common_prefix.find(prefix)
    if pos < 0:
      fail("could not find prefix: {prefix} in the common prefix: {common_prefix}".format(
          prefix = prefix,
          common_prefix = common_prefix))
    else:
      endpos = pos + len(prefix)
      actual_prefix = common_prefix[0:endpos]
      jarcmd = "{{jar}} cMf {{out}} -C {{out}}_tmp/{pf} .".format(pf=actual_prefix)

  _valid_thrift_deps(ctx.attr.deps)
  # We move the files and touch them so that the output file is a purely deterministic
  # product of the _content_ of the inputs
  cmd = """
rm -rf {out}_tmp
mkdir -p {out}_tmp
{jar} cMf {out}_tmp/tmp.jar $@
unzip -q -o {out}_tmp/tmp.jar -d {out}_tmp 2>/dev/null
rm -rf {out}_tmp/tmp.jar
find {out}_tmp -exec touch -t 198001010000 {{}} \;
""" + jarcmd + """
rm -rf {out}_tmp"""

  cmd = cmd.format(out=ctx.outputs.libarchive.path,
                   jar=ctx.file._jar.path)

  ctx.action(
    inputs = ctx.files.srcs +
      ctx.files._jar +
      ctx.files._jdk, #  We need _jdk to even run _jar. Depending on _jar is not enough with sandbox
    outputs = [ctx.outputs.libarchive],
    command = cmd,
    progress_message = "making thrift archive %s" % ctx.label,
    arguments = src_paths,
  )

  transitive_srcs = _collect_thrift_srcs(ctx.attr.deps)
  transitive_srcs += [ctx.outputs.libarchive]
  return struct(
    thrift = struct(
      srcs = ctx.outputs.libarchive,
      transitive_srcs = transitive_srcs,
    ),
  )

def _collect_thrift_attr(targets, attr):
  s = set()
  for target in targets:
    s += getattr(target.thrift, attr)
  return s

def _collect_thrift_srcs(targets):
  return _collect_thrift_attr(targets, "transitive_srcs")

def _valid_thrift_deps(targets):
  for target in targets:
    if not hasattr(target, "thrift"):
      fail("thrift_library can only depend on thrift_library", target)

# Some notes on the raison d'etre of thrift_library vs. code gen specific
# targets. The idea is to be able to separate concerns -- thrift_library is
# concerned purely with the ownership and organization of thrift files. It
# is not concerned with what to do with them. Thus, the code gen specific
# targets  will take the graph of thrift_libraries and use them to generate
# code. This organization is useful because it means that if there are
# different code generation targets, we don't need to have a whole separate
# tree of targets organizing the thrifts per code gen paradigm.
thrift_library = rule(
  implementation = _thrift_library_impl,
  attrs = {
      "srcs": attr.label_list(allow_files=_thrift_filetype),
      "deps": attr.label_list(),
      #TODO this is not necessarily the best way to do this... the goal
      # is that we want thrifts to be able to be imported via an absolute
      # path. But the thrift files have no clue what part of their path
      # should serve as the base for the import... for example, if a file is
      # in src/main/thrift/com/hello/World.thrift, if something depends on that
      # via "include 'com/hello/World.thrift'", there is no way to know what
      # path that should be relative to. One option is to just search for anything
      # that matches that, but that could create correctness issues if there are more
      # than one in different parts of the tree. Another option is to take an argument
      # that references namespace, and base the tree off of that. The downside
      # to that is that thrift_library then gets enmeshed in the details of code
      # generation. This could also be something punted to scrooge_scala_library
      # or whatever, but I think that we should make it such that the archive
      # created by this is created in such a way that absolute imports work...
      "absolute_prefix": attr.string(default='', mandatory=False),
      "_jar": attr.label(executable=True, default=Label("@bazel_tools//tools/jdk:jar"), single_file=True, allow_files=True),
      "_jdk": attr.label(default=Label("//tools/defaults:jdk"), allow_files=True),
  },
  outputs={"libarchive": "lib%{name}.jar"},
)
