package scalarules.test.scripts

import java.nio.file.Paths
import scripts.PBGenerateRequest
import org.specs2.mutable.SpecWithJUnit

class PBGenerateRequestTest extends SpecWithJUnit {
  "fixTransitiveProtoPath should fix path when included proto is available, ignore otherwise" >> {
    val includedProtos = List(Paths.get("a/b/c") -> Paths.get("a/b/c/d/e/f.proto"))
    Seq("d/e", "x/y/z").map(PBGenerateRequest.fixTransitiveProtoPath(includedProtos)) must
      beEqualTo(Seq("a/b/c/d/e", "x/y/z"))
  }

  "actual case observed in builds" >> {
    val includedProtos = List(
      Paths.get("bazel-out/k8-fastbuild/bin") ->
        Paths.get("bazel-out/k8-fastbuild/bin/external/com_google_protobuf/google/protobuf/source_context.proto"))
    Seq("external/com_google_protobuf").map(PBGenerateRequest.fixTransitiveProtoPath(includedProtos)) must
      beEqualTo(Seq("bazel-out/k8-fastbuild/bin/external/com_google_protobuf"))
  }
}