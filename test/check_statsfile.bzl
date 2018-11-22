def check_statsfile(target):
    statsfile = ":%s.statsfile" % target
    outfile = "%s.statsfile.good" % target

    cmd = """
TIME_MS=`awk -F '=' '$$1 == "build_time" {{ print $$2 }}' {statsfile}`
if [ ! -z "$$TIME_MS" ]; then
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
