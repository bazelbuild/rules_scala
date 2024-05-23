load("scaladoc.bzl", "scala_doc_intransitive")
load("//scala:scala.bzl", "scala_doc", "scala_library")
load("//scala:scala_import.bzl", "scala_import")

package(default_testonly = 1)

scala_library(
    name = "A",
    srcs = ["A.scala"],
    deps = [],
)

#B depends on A
scala_library(
    name = "B",
    srcs = ["B.scala"],
    deps = ["A"],
)

#Simulate A & B as if they were imported libraries (in particular they are targets that do not have srcs attribute)
scala_import(
    name = "ImportedA",
    jars = ["A"],
)

scala_import(
    name = "ImportedB",
    jars = ["B"],
    deps = ["ImportedA"],
)

#Setup this scala_library target so that it has dependency on a transitive external lib.
scala_library(
    name = "C",
    srcs = ["C.scala"],
    deps = [
        "ImportedB",
        #For the test, don't include ImportedA here... we want it to be loaded transitively
    ],
)

scala_doc(
    name = "scaladoc_transitive",
    deps = ["B"],
)

scala_doc_intransitive(
    name = "scaladoc_intransitive",
    deps = ["B"],
)

scala_doc(
    name = "scaladoc_C",
    deps = ["C"],
)
