load("//scala:scala.bzl",
     _scala_binary = "scala_binary",
     _scala_library = "scala_library",
     _scala_test = "scala_test",
)

def scala_binary(**kwargs):
    _scala_binary(**kwargs)

def scala_library(**kwargs):
    _scala_library(**kwargs)

def scala_test(**kwargs):
    _scala_test(**kwargs)
