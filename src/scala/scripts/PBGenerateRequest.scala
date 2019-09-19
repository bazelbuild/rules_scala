package scripts

import java.nio.file.{Files, Path, Paths}

case class PBGenerateRequest(jarOutput: String, scalaPBOutput: Path, scalaPBArgs: List[String], includedProto: List[(Path, Path)], protoc: Path, namedGenerators: Seq[(String, String)], extraJars: List[Path])

object PBGenerateRequest {

  // If there is a virtual import in the path, then
  // the path under there is pretty friendly already to protoc
  def stripToVirtual(e: String): String = {
    val v = "/_virtual_imports/"
    val idx = e.indexOf(v)
    if(idx >= 0) {
      e.drop(idx + v.size)
    } else e
  }

  def from(tmpDir: Path)(args: java.util.List[String]): PBGenerateRequest = {
    val jarOutput = args.get(0)
    val protoFiles = args.get(4).split(':')
    val protoFilesToBuild = protoFiles.map { e => s"${tmpDir.toFile.toString}/${stripToVirtual(e)}"}

    val includedProtoSplit: List[(String, String)] = args.get(1).drop(1).split(':').map { e =>
      val arr = e.split(',')
      (arr(0), arr(1))
    }.toList
    val includedProto: List[(Path, Path)] = (includedProtoSplit ++ protoFiles.toList.map { e => ("", e)}).distinct.map { case (repoPath, protoPath) =>
      // repoPath shoudl refer to the external repo root. If there is _virtual_imports this will
      // be in here too.
      //
      // If virtual imports are present we are going to prefer that for calculating our target
      // path. If not we will use relative to the external repo base.
      // if not that, just use thhe path we have.

      if(protoPath.contains("_virtual_imports")) {
        (Paths.get(protoPath), Paths.get(stripToVirtual(protoPath)))
      } else if (repoPath.nonEmpty) {
        // We have a repo specified
        // if the repo path and the file path are the same, no-op
        // otherwise get a relative path.
        val relativePath: Path = if(repoPath == protoPath) Paths.get(protoPath) else Paths.get(repoPath).relativize(Paths.get(protoPath))
        (Paths.get(protoPath), relativePath)
      } else {
        (Paths.get(protoPath), Paths.get(protoPath))
      }
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
    transitiveProtoPathFlags.map(stripToVirtual).map(s"--proto_path=${tmpDir.toFile.toString}/"+_).map(_.stripSuffix("."))

}
