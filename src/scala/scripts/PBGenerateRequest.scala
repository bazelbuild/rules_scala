package scripts

import java.nio.file.{Files, Path, Paths}

class PBGenerateRequest(val jarOutput: String, val scalaPBOutput: Path, val scalaPBArgs: List[String])

object PBGenerateRequest {
  def from(args: java.util.List[String]): PBGenerateRequest = {
    val jarOutput = args.get(0)
    val parsedProtoFiles = args.get(1).split(':').toList.map { rootAndFile =>
      val parsed = rootAndFile.split(',')
      val root = parsed(0)
      val file = if (root.isEmpty) {
        parsed(1)
      } else {
        parsed(1).substring(root.length + 1)
      }
      (file, Paths.get(root, file).toString)
    }
    // This will map the absolute path of a given proto file
    // to a relative path that does not contain the repo prefix.
    // This is to match the expected behavior of
    // proto_library and java_proto_library where proto files
    // can import other proto files using only the relative path
    val imports = parsedProtoFiles.map { case (relPath, absolutePath) =>
      s"-I$relPath=$absolutePath"
    }
    val protoFiles = parsedProtoFiles.map(_._2)
    val flagOpt = args.get(2) match {
      case "-" => None
      case s if s.charAt(0) == '-' => Some(s.tail) //drop padding character
      case other => sys.error(s"expected a padding character of - (dash), but found: $other")
    }

    val tmp = Paths.get(Option(System.getProperty("java.io.tmpdir")).getOrElse("/tmp"))
    val scalaPBOutput = Files.createTempDirectory(tmp, "bazelscalapb")
    val flagPrefix = flagOpt.fold("")(_ + ":")
    val scalaPBArgs = s"--scala_out=$flagPrefix$scalaPBOutput" :: (imports ++ protoFiles)
    new PBGenerateRequest(jarOutput, scalaPBOutput, scalaPBArgs)
  }
}