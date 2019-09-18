package scripts

import java.io.PrintStream
import java.nio.file.{Path, FileAlreadyExistsException}

import io.bazel.rulesscala.io_utils.DeleteRecursively
import io.bazel.rulesscala.jar.JarCreator
import io.bazel.rulesscala.worker.{GenericWorker, Processor}
import protocbridge.{ProtocBridge, ProtocCodeGenerator}
import scala.collection.JavaConverters._
import scalapb.ScalaPbCodeGenerator
import java.nio.file.{Files, Paths}
import scalapb.{ScalaPBC, ScalaPbCodeGenerator, ScalaPbcException}
import java.net.URLClassLoader
import scala.util.{Try, Failure}

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
  def setupIncludedProto(tmpRoot: Path, includedProto: List[(Path, Path)]): Unit = {
    includedProto.foreach { case (root, fullPath) =>
      require(fullPath.toFile.exists, s"Path $fullPath does not exist, which it should as a dependency of this rule")
      val relativePath = if(root == fullPath) fullPath else root.relativize(fullPath)
      val targetPath = tmpRoot.resolve(relativePath)

      targetPath.toFile.getParentFile.mkdirs
      Try(Files.copy(fullPath, targetPath)) match {
        case Failure(err: FileAlreadyExistsException) =>
          Console.println(s"File already exists, skipping copy from $fullPath to $targetPath: ${err.getMessage}")
        case Failure(err) => throw err
        case _ => ()
      }
    }
  }
  def deleteDir(path: Path): Unit =
    try DeleteRecursively.run(path)
    catch {
      case e: Exception => sys.error(s"Problem while deleting path [$path], e.getMessage= ${e.getMessage}")
    }

  def processRequest(args: java.util.List[String]) {
    val tmpRoot = Files.createTempDirectory("proto_builder")

    val extractRequestResult = PBGenerateRequest.from(tmpRoot)(args)
    setupIncludedProto(tmpRoot, extractRequestResult.includedProto)

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
      deleteDir(tmpRoot)
      deleteDir(extractRequestResult.scalaPBOutput)
    }
  }

  protected def exec(protoc: Path): Seq[String] => Int = (args: Seq[String]) => {
    val tmpFile = Files.createTempFile("stdout", "log")
    try {
      val ret = new ProcessBuilder(protoc.toString +: args: _*).redirectErrorStream(true).redirectOutput(ProcessBuilder.Redirect.to(tmpFile.toFile)).start().waitFor()
      Try {
        scala.io.Source.fromFile(tmpFile.toFile).getLines.foreach{System.out.println}
      }
      ret
    } finally {
      tmpFile.toFile.delete
    }
  }
}
