package scripts

import java.nio.file.{Files, Path, Paths}

case class PBGenerateRequest(jarOutput: String, scalaPBOutput: Path, scalaPBArgs: List[String], includedProto: List[(Path, Path)], protoc: Path, namedGenerators: Seq[(String, String)], extraJars: List[Path])

object PBGenerateRequest {

  def from(tmpDir: Path)(args: java.util.List[String]): PBGenerateRequest = {
    val jarOutput = args.get(0)
    val protoFiles = args.get(4).split(':')
    val protoFilesToBuild = protoFiles.map { e => s"${tmpDir.toFile.toString}/$e"}

    val includedProto = args.get(1).drop(1).split(':').distinct.map { e =>
      val p = e.split(',')
      // If its an empty string then it means we are local to the current repo for the key, no op
      val absolutePath = Some(p(0)).filter(_.nonEmpty).getOrElse(p(1))
      (Paths.get(absolutePath), Paths.get(p(1)))
    }.toList ++ protoFiles.map { p => (Paths.get(p), Paths.get(p))}

    val flagOpt = args.get(2) match {
      case "-" => None
      case s if s.charAt(0) == '-' => Some(s.tail) //drop padding character
      case other => sys.error(s"expected a padding character of - (dash), but found: $other")
    }
    val transitiveProtoPaths = (args.get(3) match {
      case "-" => Nil
      case s if s.charAt(0) == '-' => s.tail.split(':').toList //drop padding character
      case other => sys.error(s"expected a padding character of - (dash), but found: $other")
    }) ++ List("")

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


    val scalaPBArgs = outputSettings ::: (padWithProtoPathPrefix(tmpDir)(transitiveProtoPaths) ++ protoFilesToBuild)

    val protoc = Paths.get(args.get(5))

    val extraJars = args.get(7).drop(1).split(':').filter(_.nonEmpty).distinct.map {e => Paths.get(e)}.toList

    new PBGenerateRequest(jarOutput, scalaPBOutput, scalaPBArgs, includedProto, protoc, namedGenerators, extraJars)
  }

  private def padWithProtoPathPrefix(tmpDir: Path)(transitiveProtoPathFlags: List[String]) =
    transitiveProtoPathFlags.map(s"--proto_path=${tmpDir.toFile.toString}/"+_).map(_.stripSuffix("."))

}
