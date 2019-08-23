load(
    "//scala_thrift:scala_thrift.bzl",
    "scala_thrift_import",
    "scala_thrift_library",
    "scala_thrift_repositories",
)

def scrooge_scala_import(**kwargs):
    return scala_thrift_import(**kwargs)

def scrooge_scala_library(**kwargs):
    return scala_thrift_library(**kwargs)

def twitter_scrooge(**kwargs):
    return scala_thrift_repositories(**kwargs)
