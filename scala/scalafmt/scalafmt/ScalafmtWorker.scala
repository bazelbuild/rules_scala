package io.bazel.rules_scala.scalafmt

import io.bazel.rulesscala.worker.Worker
import java.io.File
import java.nio.file.Files
import org.scalafmt.Scalafmt
import scala.annotation.tailrec
import scala.io.Codec

object ScalafmtWorker extends Worker.Interface {

  def main(args: Array[String]): Unit = Worker.workerMain(args, ScalafmtWorker)

  def work(args: Array[String]): Unit = {
    val argName = List("config", "input", "output")
    val argFile = args.map{x => new File(x)}
    val namespace = argName.zip(argFile).toMap

    val sourceFile = namespace.getOrElse("input", new File(""))
    val source = ScalafmtAdapter.readFile(sourceFile)(Codec.UTF8)

    val configFile = namespace.getOrElse("config", new File(""))
    val config = ScalafmtAdapter.parseConfigFile(configFile)

    @tailrec
    def format(code: String): String = {
      val filePath = sourceFile.getPath()
      val formatted = Scalafmt.format(code, config, Set.empty, filePath).get
      if (code == formatted) code else format(formatted)
    }

    val output = try {
      format(source)
    } catch {
      case e @ (_: org.scalafmt.Error | _: scala.meta.parsers.ParseException) => {
        System.out.println("Unable to format file due to bug in scalafmt")
        System.out.println(e.toString)
        source
      }
    }

    Files.write(namespace.getOrElse("output", new File("")).toPath, output.getBytes)
  }
}
