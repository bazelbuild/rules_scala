package tests

import java.io.PrintStream
import java.nio.file.Path

import com.trueaccord.scalapb.{ScalaPBC, ScalaPbcException}
import io.bazel.rulesscala.jar.JarCreator
import io.bazel.rulesscala.worker.{GenericWorker, Processor}
import protocbridge.ProtocBridge
import scala.collection.JavaConverters._
import scalapb.ScalaPbCodeGenerator
import java.nio.file.{Files, Paths}
import scripts._

object CustomScalaPBWorker extends GenericWorker(new CustomScalaPBGenerator) {

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

class CustomScalaPBGenerator extends ScalaPBGenerator {
  override def processRequest(args: java.util.List[String]) {
    val a: Array[String] = args.asScala.toArray[String]

    // flat package doesn't seem to work with different things
    a(2) = "-flat_package"

    val extractRequestResult = PBGenerateRequest.from(a.toList.asJava)

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
}
