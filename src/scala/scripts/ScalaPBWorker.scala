package scripts

import java.io.PrintStream
import java.nio.file.{Path, FileAlreadyExistsException}

import io.bazel.rulesscala.io_utils.DeleteRecursively
import io.bazel.rulesscala.jar.JarCreator
import io.bazel.rulesscala.worker.Worker
import protocbridge.{ProtocBridge, ProtocCodeGenerator}
import scala.collection.JavaConverters._
import scalapb.ScalaPbCodeGenerator
import java.nio.file.{Files, Paths}
import scalapb.{ScalaPBC, ScalaPbCodeGenerator, ScalaPbcException}
import java.net.URLClassLoader
import scala.util.{Try, Failure}

object ScalaPBWorker extends Worker.Interface {

  def main(args: Array[String]): Unit = Worker.workerMain(args, ScalaPBWorker)

  def deleteDir(path: Path): Unit =
    try DeleteRecursively.run(path)
    catch {
      case e: Exception => sys.error(s"Problem while deleting path [$path], e.getMessage= ${e.getMessage}")
    }

  def work(args: Array[String]) {
    val extractRequestResult = PBGenerateRequest.from(args)
    val extraClassesClassLoader = new URLClassLoader(extractRequestResult.extraJars.map { e =>
      val f = e.toFile
      require(f.exists, s"Expected file for classpath loading $f to exist")
      f.toURI.toURL
    }.toArray)

    val namedGeneratorsWithTypes = extractRequestResult.namedGenerators.map { case (nme, className) =>
      val ins = try {
        val clazz = extraClassesClassLoader.loadClass(className + "$")
        clazz.getField("MODULE$").get(null).asInstanceOf[ProtocCodeGenerator]
      } catch {
        case _: NoSuchFieldException | _: java.lang.ClassNotFoundException =>
    val clazz = extraClassesClassLoader.loadClass(className)
    clazz.newInstance.asInstanceOf[ProtocCodeGenerator]
      }
      (nme, ins)
    }.toList

    val config = ScalaPBC.processArgs(extractRequestResult.scalaPBArgs.toArray)

    val code = ProtocBridge.runWithGenerators(
      protoc = exec(extractRequestResult.protoc),
      namedGenerators = namedGeneratorsWithTypes ++ Seq("scala" -> ScalaPbCodeGenerator),
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
