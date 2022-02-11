package scripts

import java.io.File.pathSeparatorChar
import java.net.URLClassLoader
import java.nio.file.{Files, Paths}

import io.bazel.rulesscala.worker.Worker
import protocbridge.{ProtocBridge, ProtocCodeGenerator}

import scala.sys.process._

object ScalaPBWorker extends Worker.Interface {

  private val protoc = {
    val executable = sys.props.getOrElse("PROTOC", sys.error("PROTOC not supplied"))
    (args: Seq[String]) => Process(executable, args).!(ProcessLogger(stderr.println(_)))
  }

  private val classes = {
    val jars = sys.props.getOrElse("JARS", "").split(pathSeparatorChar).filter(_.nonEmpty).map { e =>
      val file = Paths.get(e)
      require(Files.exists(file), s"Expected file for classpath loading $file to exist")
      file.toUri.toURL
    }
    new URLClassLoader(jars).loadClass(_)
  }

  private val generator = (className: String) => try {
    classes(className + "$").getField("MODULE$").get(null).asInstanceOf[ProtocCodeGenerator]
  } catch {
    case _: NoSuchFieldException | _: java.lang.ClassNotFoundException =>
      classes(className).newInstance.asInstanceOf[ProtocCodeGenerator]
  }

  private val generators: Seq[(String, ProtocCodeGenerator)] = sys.props.toSeq.collect {
    case (k, v) if k.startsWith("GEN_") => k.stripPrefix("GEN_") -> generator(v)
  }

  def main(args: Array[String]): Unit = Worker.workerMain(args, ScalaPBWorker)

  def work(args: Array[String]): Unit = {
    val code = ProtocBridge.runWithGenerators(protoc, generators, args)
    if (code != 0) {
      sys.error(s"Exit with code $code")
    }
  }

}
