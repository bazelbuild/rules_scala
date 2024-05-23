load("//scala:scala.bzl", "make_scala_doc_rule", "scaladoc_intransitive_aspect")

scala_doc_intransitive = make_scala_doc_rule(scaladoc_intransitive_aspect) #Only scaladoc specified deps