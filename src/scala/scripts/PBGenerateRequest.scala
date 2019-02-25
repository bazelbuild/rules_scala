package scripts

import java.nio.file.{Files, Path, Paths}

class PBGenerateRequest(val jarOutput: String, val scalaPBOutput: Path, val scalaPBArgs: List[String], val includedProto: List[(String, String)])

object PBGenerateRequest {

  def from(args: java.util.List[String]): PBGenerateRequest = {
    val jarOutput = args.get(0)
    val protoFiles = args.get(4).split(':')
    val includedProto = args.get(1).drop(1).split(':').distinct.map { e =>
      val p = e.split(',')
      (p(0), p(1))
    }.filter { case (k, v) =>
    // If its an empty string then it means we are local to the current repo for the key, no op
    // or if the to compile files contains this absolute path then we are compiling it and shoudln't try move it around(duplicate files.)
    k != "" && !protoFiles.contains(v)}.toList

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
    val scalaPBArgs = s"--scala_out=$flagPrefix$scalaPBOutput" :: (padWithProtoPathPrefix(transitiveProtoPaths) ++ protoFiles)
    new PBGenerateRequest(jarOutput, scalaPBOutput, scalaPBArgs, includedProto)
  }

  private def padWithProtoPathPrefix(transitiveProtoPathFlags: List[String]) =
    transitiveProtoPathFlags.map("--proto_path="+_)

}
