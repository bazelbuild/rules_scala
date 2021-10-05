def check_2010(target):
    statsfile = ":%s.statsfile" % target
    outfile = "%s.statsfile.good" % target

    cmd = """
TIMESTAMP=`TZ=UTC date -r {statsfile} "+%Y-%m-%d %H:%M:%S"`
if [ "$$TIMESTAMP" == "2010-01-01 00:00:00" ]; then
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
