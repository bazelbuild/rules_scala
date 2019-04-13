package scripts

import java.io.PrintStream
import java.nio.file.Path

import io.bazel.rulesscala.io_utils.DeleteRecursively
import io.bazel.rulesscala.jar.JarCreator
import io.bazel.rulesscala.worker.{GenericWorker, Processor}
import protocbridge.ProtocBridge
import scala.collection.JavaConverters._
import scalapb.ScalaPbCodeGenerator
import java.nio.file.{Files, Paths}
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
  def setupIncludedProto(includedProto: List[(Path, Path)]): Unit = {
    includedProto.foreach { case (root, fullPath) =>
      require(fullPath.toFile.exists, s"Path $fullPath does not exist, which it should as a dependency of this rule")
      val relativePath = root.relativize(fullPath)

      relativePath.toFile.getParentFile.mkdirs
      Files.copy(fullPath, relativePath)
    }
  }
  def deleteDir(path: Path): Unit =
    try DeleteRecursively.run(path)
    catch {
      case e: Exception => sys.error(s"Problem while deleting path [$path], e.getMessage= ${e.getMessage}")
    }

  def processRequest(args: java.util.List[String]) {
    val extractRequestResult = PBGenerateRequest.from(args)
    setupIncludedProto(extractRequestResult.includedProto)

    val config = ScalaPBC.processArgs(extractRequestResult.scalaPBArgs.toArray)
    val code = ProtocBridge.runWithGenerators(
      protoc = exec(extractRequestResult.protoc),
      namedGenerators = Seq("scala" -> ScalaPbCodeGenerator),
      params = config.args)

    try {
        if (code != 0) {
          throw new ScalaPbcException(s"Exit with code $code")
        }
        JarCreator.buildJar(Array(extractRequestResult.jarOutput, extractRequestResult.scalaPBOutput.toString))
    } finally {
      deleteDir(extractRequestResult.scalaPBOutput)
    }
  }

  protected def exec(protoc: Path): Seq[String] => Int = (args: Seq[String]) =>
    new ProcessBuilder(protoc.toString +: args: _*).inheritIO().start().waitFor()
}
