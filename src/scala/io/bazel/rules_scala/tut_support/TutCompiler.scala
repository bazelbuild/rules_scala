package io.bazel.rules_scala.tut_support

import io.bazel.rulesscala.io_utils.DeleteRecursively
import java.io.File
import java.nio.file.{ Files, Paths }
import tut.TutMain

object TutCompiler {
  def main(args: Array[String]): Unit = {
    val tmp = Paths.get(Option(System.getenv("TMPDIR")).getOrElse("/tmp"))
    val mdOutput = Files.createTempDirectory(tmp, "tut")
    val outfile = args(1)
    TutMain.main(Array(args(0), mdOutput.toString, ".*\\.md$"))
    // Now move the single md file in that directory onto outfile
    mdOutput.toFile.listFiles.toList match {
      case List(path) =>
        // expect exactly one output
        if (!path.renameTo(new File(outfile))) {
          System.err.println(s"could not move $path to $outfile")
          System.exit(1)
        }
        else {
          // remove the tmp directory
          DeleteRecursively.run(mdOutput)
          println(s"wrote: $outfile")
        }
      case many =>
          System.err.println(s"expected one file in $mdOutput, found: $many")
          System.exit(1)
    }
  }
}

