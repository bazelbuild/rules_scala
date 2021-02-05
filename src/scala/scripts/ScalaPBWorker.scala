package scripts

import java.io.File.pathSeparatorChar
import java.net.URLClassLoader
import java.nio.file.Paths

import io.bazel.rulesscala.worker.Worker
import protocbridge.{ProtocBridge, ProtocCodeGenerator}

import scala.sys.process._

object ScalaPBWorker extends Worker.Interface {

  private val protoc = {
    val executable = sys.env.getOrElse("PROTOC", sys.error("PROTOC env variable not found."))
    (args: Seq[String]) => Process(executable, args).!(ProcessLogger(stderr.println(_)))
  }

  private val classpath = {
    val jars = sys.env.getOrElse("EXTRA_JARS", "").split(pathSeparatorChar).map { e =>
      val file = Paths.get(e).toFile
      require(file.exists, s"Expected file for classpath loading $file to exist")
      file.toURI.toURL
    }
    val loader = new URLClassLoader(jars)

    (className: String) =>
      try {
        val clazz = loader.loadClass(className + "$")
        clazz.getField("MODULE$").get(null).asInstanceOf[ProtocCodeGenerator]
      } catch {
        case _: NoSuchFieldException | _: java.lang.ClassNotFoundException =>
          val clazz = loader.loadClass(className)
          clazz.newInstance.asInstanceOf[ProtocCodeGenerator]
      }
  }

  private val generators: Seq[(String, ProtocCodeGenerator)] = sys.env.toSeq.collect {
    case (k, v) if k.startsWith("GEN_") => k.stripPrefix("GEN_") -> classpath(v)
  }

  def main(args: Array[String]): Unit = Worker.workerMain(args, ScalaPBWorker)

  def work(args: Array[String]) {
    val code = ProtocBridge.runWithGenerators(protoc, generators, args)
    if (code != 0) {
      sys.error(s"Exit with code $code")
    }
  }

}
