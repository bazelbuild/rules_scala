"""Rules for organizing thrift files."""

_thrift_filetype = FileType([".thrift"])

def _thrift_library_impl(ctx):
  _valid_thrift_deps(ctx.attr.deps)
  # We move the files and touch them so that the output file is a purely deterministic
  # product of the _content_ of the inputs
  #TODO is rsync an acceptable dependency here?
  cmd = """
rm -rf {out}_tmp
mkdir -p {out}_tmp
{jar} cMf {out}_tmp/tmp.jar $@
unzip -o {out}_tmp/tmp.jar -d {out}_tmp >/dev/null
rm -rf {out}_tmp/tmp.jar
find {out}_tmp -exec touch -t 198001010000 {{}} \;
{jar} cMf {out} -C {out}_tmp .
rm -rf {out}_tmp""".format(out=ctx.outputs.libarchive.path,
                           jar=ctx.file._jar.path)
  ctx.action(
    inputs = ctx.files.srcs,
    outputs = [ctx.outputs.libarchive],
    command = cmd,
    progress_message = "making thrift archive %s" % ctx.label,
    arguments = [f.path for f in ctx.files.srcs],
  )
  transitive_archives = _collect_thrift_tars(ctx.attr.deps)
  transitive_archives += [ctx.outputs.libarchive]

  transitive_srcs = _collect_thrift_srcs(ctx.attr.deps)
  transitive_srcs += ctx.files.srcs
  return struct(
    srcs = ctx.files.srcs,
    thrift = struct(
      transitive_srcs = transitive_srcs,
      transitive_archives = transitive_archives,
    ),
  )

def _collect_thrift_attr(targets, attr):
  s = set()
  for target in targets:
    s += getattr(target.thrift, attr)
  return s

def _collect_thrift_tars(targets):
  return _collect_thrift_attr(targets, "transitive_archives")

def _collect_thrift_srcs(targets):
  return _collect_thrift_attr(targets, "transitive_srcs")

def _valid_thrift_deps(targets):
  for target in targets:
    if not hasattr(target, "thrift"):
      fail("thrift_library can only depend on thrift_library", target)

# Some notes on the raison d'etre of thrift_library vs. scrooge_scala_library.
# The idea is to be able to separate concerns -- thrift_library is concerned
# with the ownership of thrift files, and organizing them into targets. It is
# not concerned with how the process of converting thrifts into sources. Thus,
# the scrooge_scala_library is what handles the specifics of code generation...
# this is useful because it means that if there are different code generation
# targets, we don't need to have a whole separate tree of targets organizing
# the thrifts.
thrift_library = rule(
  implementation = _thrift_library_impl,
  attrs = {
      "srcs": attr.label_list(allow_files=_thrift_filetype),
      "deps": attr.label_list(),
      "_jar": attr.label(executable=True, default=Label("@bazel_tools//tools/jdk:jar"), single_file=True, allow_files=True),
  },
  outputs={"libarchive": "lib%{name}.jar"},
)