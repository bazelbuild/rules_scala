package scripts

import java.io.PrintStream
import java.nio.file.Path

import io.bazel.rulesscala.io_utils.DeleteRecursively
import io.bazel.rulesscala.jar.JarCreator
import io.bazel.rulesscala.worker.{GenericWorker, Processor}
import protocbridge.ProtocBridge
import scalapb.{ScalaPBC, ScalaPbCodeGenerator, ScalaPbcException}

object ScalaPBWorker extends GenericWorker(new ScalaPBGenerator) {

  override protected def setupOutput(ps: PrintStream): Unit = {
    System.setOut(ps)
    System.setErr(ps)
    Console.setErr(ps)
    Console.setOut(ps)
  }

  def main(args: Array[String]) {
    try run(args)
    catch {
      case x: Exception =>
        x.printStackTrace()
        System.exit(1)
    }
  }
}

class ScalaPBGenerator extends Processor {
  def deleteDir(path: Path): Unit =
    try DeleteRecursively.run(path)
    catch {
      case e: Exception => sys.error(s"Problem while deleting path [$path], e.getMessage= ${e.getMessage}")
    }

  def processRequest(args: java.util.List[String]) {
    val extractRequestResult = PBGenerateRequest.from(args)
    val config = ScalaPBC.processArgs(extractRequestResult.scalaPBArgs.toArray)
    val code = ProtocBridge.runWithGenerators(
      protoc = exec(extractRequestResult.protoc),
      namedGenerators = Seq("scala" -> ScalaPbCodeGenerator),
      params = config.args)

    try {
      if (!config.throwException) {
        JarCreator.buildJar(Array(extractRequestResult.jarOutput, extractRequestResult.scalaPBOutput.toString))
      } else {
        if (code != 0) {
          throw new ScalaPbcException(s"Exit with code $code")
        }
      }
    } finally {
      deleteDir(extractRequestResult.scalaPBOutput)
    }
  }

  private def exec(protoc: String): Seq[String] => Int = (args: Seq[String]) =>
    new ProcessBuilder(protoc +: args: _*).inheritIO().start().waitFor()
}
