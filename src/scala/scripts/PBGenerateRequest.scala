package scripts

import java.nio.file.{Files, Path, Paths}

case class PBGenerateRequest(jarOutput: String, scalaPBOutput: Path, scalaPBArgs: List[String], includedProto: List[(Path, Path)], protoc: Path, namedGenerators: Seq[(String, String)], extraJars: List[Path])

object PBGenerateRequest {

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
    }) ++ List(".")

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
