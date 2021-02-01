package scripts

import java.net.URLClassLoader
import java.nio.file.Path

import io.bazel.rulesscala.io_utils.DeleteRecursively
import io.bazel.rulesscala.jar.JarCreator
import io.bazel.rulesscala.worker.Worker
import protocbridge.{ProtocBridge, ProtocCodeGenerator}

import scala.sys.process._

object ScalaPBWorker extends Worker.Interface {

  private val MainGenerator = {
    val className = sys.env.getOrElse("MAIN_GENERATOR", sys.error("MAIN_GENERATOR env variable not found."))
    val classLoader = getClass.getClassLoader
    classLoader.loadClass(className + "$").getField("MODULE$").get(null).asInstanceOf[ProtocCodeGenerator]
  }

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

    val code = ProtocBridge.runWithGenerators(
      protoc = exec(extractRequestResult.protoc),
      namedGenerators = namedGeneratorsWithTypes :+ ("scala", MainGenerator),
      params = extractRequestResult.scalaPBArgs)

    try {
      if (code != 0) {
        sys.error(s"Exit with code $code")
      }
      JarCreator.buildJar(Array(extractRequestResult.jarOutput, extractRequestResult.scalaPBOutput.toString))
    } finally {
      deleteDir(extractRequestResult.scalaPBOutput)
    }
  }

  protected def exec(protoc: Path): Seq[String] => Int = (args: Seq[String]) =>
    Process(protoc.toString, args).!(ProcessLogger(stderr.println(_)))
}
