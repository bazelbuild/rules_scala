load("//scala:scala.bzl", "scala_library")

def create_dependencies(amount, length):
    for i in range(amount):
        scala_library(name = "dependency_" * length + str(i))

def get_dependency_labels(amount, length):
    return [":" + "dependency_" * length + str(i) for i in range(amount)]
