package io.bazel.rules_scala.scalafmt

import io.bazel.rulesscala.worker.{GenericWorker, Processor};
import java.io.File
import java.nio.file.Files
import net.sourceforge.argparse4j.ArgumentParsers
import net.sourceforge.argparse4j.impl.Arguments
import org.scalafmt.Scalafmt
import org.scalafmt.config.Config
import org.scalafmt.util.FileOps
import scala.annotation.tailrec
import scala.io.Codec

object ScalafmtRunner extends GenericWorker(new ScalafmtProcessor) {
  def main(args: Array[String]) {
    try run(args)
    catch {
      case x: Exception =>
        x.printStackTrace()
        System.exit(1)
    }
  }
}

class ScalafmtProcessor extends Processor {
  def processRequest(args: java.util.List[String]) {
    var argsArrayBuffer = scala.collection.mutable.ArrayBuffer[String]()
    for (i <- 0 to args.size-1) {
      argsArrayBuffer += args.get(i)
    }
    val parser = ArgumentParsers.newFor("scalafmt").addHelp(true).defaultFormatWidth(80).fromFilePrefix("@").build
    parser.addArgument("--config").required(true).`type`(Arguments.fileType)
    parser.addArgument("input").`type`(Arguments.fileType)
    parser.addArgument("output").`type`(Arguments.fileType)

    val namespace = parser.parseArgsOrFail(argsArrayBuffer.toArray)

    val source = FileOps.readFile(namespace.get[File]("input"))(Codec.UTF8)

    val config = Config.fromHoconFile(namespace.get[File]("config")).get
    @tailrec
    def format(code: String): String = {
      val formatted = Scalafmt.format(code, config).get
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

    Files.write(namespace.get[File]("output").toPath, output.getBytes)
  }
}
