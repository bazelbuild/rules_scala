package scripts

import java.nio.file.{Files, Path, Paths}

case class PBGenerateRequest(jarOutput: String, scalaPBOutput: Path, scalaPBArgs: List[String], includedProto: List[(Path, Path)], protoc: Path, namedGenerators: Seq[(String, String)], extraJars: List[Path])

object PBGenerateRequest {

  // This little function fixes a problem, where external/com_google_protobuf is not found. The com_google_protobuf
  // is special in a way that it also brings-in protoc and also google well-known proto files. This, possibly,
  // confuses Bazel and external/com_google_protobuf is not made available for target builds. Actual causes are unknown
  // and this fixTransitiveProtoPath fixes this problem in the following way:
  //  (1) We have a list of all required .proto files; this is a tuple list (root -> full path), for example:
  //        bazel-out/k8-fastbuild/bin -> bazel-out/k8-fastbuild/bin/external/com_google_protobuf/google/protobuf/source_context.proto
  //  (2) Convert the full path to relative from the root:
  //        bazel-out/k8-fastbuild/bin -> external/com_google_protobuf/google/protobuf/source_context.proto
  //  (3) From all the included protos we find the first one that is located within dir we are processing -- relative
  //      path starts with the dir we are processing
  //  (4) If found -- the include folder is "orphan" and is not anchored in either host or target. To fix we prepend
  //      root. If not found, return original. This works as long as "external/com_google_protobuf" is available in
  //      target root.
  def fixTransitiveProtoPath(includedProto: List[(Path, Path)])(orig: String): String = includedProto
      .map  { case (root, full) => (root, root.relativize(full)) }
      .find { case (_, rel)     => rel.toString.startsWith(orig) }
      .map  { case (root, _)    => root.toString + "/" + orig    }
      .getOrElse(orig)

  def from(args: java.util.List[String]): PBGenerateRequest = {
    val jarOutput = args.get(0)
    val protoFiles = args.get(4).split(':')
    val includedProto = args.get(1).drop(1).split(':').distinct.map { e =>
      val p = e.split(',')
      // If its an empty string then it means we are local to the current repo for the key, no op
      (Some(p(0)).filter(_.nonEmpty), p(1))
    }.collect {
      // if the to compile files contains this absolute path then we are compiling it and shoudln't try move it around(duplicate files.)
      case (Some(k), v) if !protoFiles.contains(v) => (Paths.get(k), Paths.get(v))
    }.toList

    val flagOpt = args.get(2) match {
      case "-" => None
      case s if s.charAt(0) == '-' => Some(s.tail) //drop padding character
      case other => sys.error(s"expected a padding character of - (dash), but found: $other")
    }
    val transitiveProtoPaths = (args.get(3) match {
      case "-" => Nil
      case s if s.charAt(0) == '-' => s.tail.split(':').toList //drop padding character
      case other => sys.error(s"expected a padding character of - (dash), but found: $other")
    }).map(fixTransitiveProtoPath(includedProto)) ++ List(".")

    val tmp = Paths.get(Option(System.getProperty("java.io.tmpdir")).getOrElse("/tmp"))
    val scalaPBOutput = Files.createTempDirectory(tmp, "bazelscalapb")
    val flagPrefix = flagOpt.fold("")(_ + ":")

    val namedGenerators = args.get(6).drop(1).split(',').filter(_.nonEmpty).map { e =>
      val kv = e.split('=')
      (kv(0), kv(1))
    }

    val outputSettings = s"--scala_out=$flagPrefix$scalaPBOutput" :: namedGenerators.map{ case (k, _) =>
      s"--${k}_out=$flagPrefix$scalaPBOutput"
    }.toList


    val scalaPBArgs = outputSettings ::: (padWithProtoPathPrefix(transitiveProtoPaths) ++ protoFiles)
    val protoc = Paths.get(args.get(5))

    val extraJars = args.get(7).drop(1).split(':').filter(_.nonEmpty).distinct.map {e => Paths.get(e)}.toList

    new PBGenerateRequest(jarOutput, scalaPBOutput, scalaPBArgs, includedProto, protoc, namedGenerators, extraJars)
  }

  private def padWithProtoPathPrefix(transitiveProtoPathFlags: List[String]) =
    transitiveProtoPathFlags.map("--proto_path="+_)

}
