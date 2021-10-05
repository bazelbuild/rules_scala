def check_statsfile(target):
    _check_statsfile(target, "!")

def check_statsfile_empty(target):
    _check_statsfile(target)

def _check_statsfile(target, predicate = ""):
    statsfile = ":%s.statsfile" % target
    outfile = "%s.statsfile.good" % target

    cmd = """
TIME_MS=`awk -F '=' '$$1 == "build_time" {{ print $$2 }}' {statsfile}`
if [ """ + predicate + """ -z "$$TIME_MS" ]; then
  touch '{outfile}'
fi
"""
    cmd = cmd.format(
        statsfile = "$(location %s)" % statsfile,
        outfile = "$(location %s)" % outfile,
    )

    native.genrule(
        name = "%s_statsfile" % target,
        outs = [outfile],
        tools = [statsfile],
        cmd = cmd,
        visibility = ["//visibility:public"],
    )
