package io.bazel.rules_scala.jmh_support

import java.net.URLClassLoader

import scala.collection.JavaConverters._
import org.openjdk.jmh.generators.core.{FileSystemDestination, GeneratorSource, BenchmarkGenerator => JMHGenerator}
import org.openjdk.jmh.generators.asm.ASMGeneratorSource
import org.openjdk.jmh.generators.reflection.RFGeneratorSource
import java.net.URI

import scala.collection.JavaConverters._
import java.nio.file.{FileSystems, Files, Path}

import io.bazel.rulesscala.jar.JarCreator


/**
 * Wrapper around JMH generator code to find JMH benchmarks and emit generated
 * code for running them.
 *
 * This implementation is derived from Thomas Switzer's excellent `sbt` plugin,
 * `sbt-benchmark`. His original implementation may be found here:
 * https://github.com/tixxit/sbt-benchmark/blob/master/src/main/scala/net/tixxit/sbt/benchmark/BenchmarkPlugin.scala
 */
object BenchmarkGenerator {

  private sealed trait GeneratorType

  private case object ReflectionGenerator extends GeneratorType

  private case object AsmGenerator extends GeneratorType

  private case class BenchmarkGeneratorArgs(
    generatorType: GeneratorType,
    inputJar: Path,
    resultSourceJar: Path,
    resultResourceJar: Path,
    classPath: List[Path]
  )

  private case class GenerationException(messageLines: Seq[String])
    extends RuntimeException(messageLines.mkString("\n"))

  def main(argv: Array[String]): Unit = {
    val args = parseArgs(argv)
    try {
      generateJmhBenchmark(
        args.generatorType,
        args.resultSourceJar,
        args.resultResourceJar,
        args.inputJar,
        args.classPath
      )
    } catch {
      case GenerationException(messageLines) =>
        messageLines.foreach(log)
        sys.exit(1)
    }
  }

  private def parseArgs(argv: Array[String]): BenchmarkGeneratorArgs = {
    if (argv.length < 3) {
      System.err.println(
        "Usage: BenchmarkGenerator GENERATOR_TYPE INPUT_JAR RESULT_JAR RESOURCE_JAR [CLASSPATH_ELEMENT] [CLASSPATH_ELEMENT...]"
      )
      System.exit(1)
    }
    val fs = FileSystems.getDefault

    BenchmarkGeneratorArgs(
      parseGeneratorType(argv(0)),
      fs.getPath(argv(1)),
      fs.getPath(argv(2)),
      fs.getPath(argv(3)),
      argv.slice(4, argv.length).map { s => fs.getPath(s) }.toList
    )
  }

  private def listFiles(dir: Path): List[Path] = {
    val stream = Files.newDirectoryStream(dir)
    stream.asScala.toList
  }

  private def listFilesRecursively(root: Path)(pred: Path => Boolean): List[Path] = {
    def loop(fs0: List[Path], files: List[Path]): List[Path] = fs0 match {
      case f :: fs if Files.isDirectory(f) => loop(fs ++ listFiles(f), files)
      case f :: fs if pred(f) => loop(fs, f :: files)
      case _ :: fs => loop(fs, files)
      case Nil => files.reverse
    }

    loop(root :: Nil, Nil)
  }

  private def collectClassesFromJar(root: Path): List[Path] = {
    val path = if (System.getProperty("os.name").toLowerCase().contains("windows"))
      "/" + root.toFile.getAbsolutePath.replaceAll("\\\\", "/")
    else
      root.toFile.getAbsolutePath
    val uri = new URI("jar:file", null, path, null)
    val fs = FileSystems.newFileSystem(uri, Map.empty[String, String].asJava)
    fs.getRootDirectories.asScala.toList.flatMap { rootDir =>
      listFilesRecursively(rootDir) { (path: Path) =>
        path.getFileName.toString.endsWith(".class")
      }
    }
  }

  // Courtesy of Doug Tangren (https://groups.google.com/forum/#!topic/simple-build-tool/CYeLHcJjHyA)
  private def withClassLoader[A](cp: Seq[Path])(f: ClassLoader => A): A = {
    val originalLoader = Thread.currentThread.getContextClassLoader
    val jmhLoader = classOf[JMHGenerator].getClassLoader
    val classLoader = new URLClassLoader(cp.map(_.toUri.toURL).toArray, jmhLoader)
    try {
      Thread.currentThread.setContextClassLoader(classLoader)
      f(classLoader)
    } finally {
      Thread.currentThread.setContextClassLoader(originalLoader)
    }
  }

  private def withTempDirectory[A](f: Path => A): A = {
    val tempDir = Files.createTempDirectory("jmh_benchmark_generator")
    try {
      f(tempDir)
    } finally {
      listFilesRecursively(tempDir)(_ => true).reverse.foreach {file =>
        Files.delete(file)
      }
    }
  }

  private def constructJar(output: Path, fileDir: Path): Unit = {
    val creator = new JarCreator(output.toAbsolutePath.toFile.toString)
    creator.addDirectory(fileDir.toFile)
    creator.execute
  }

  private def generateJmhBenchmark(
    generatorType: GeneratorType,
    sourceJarOut: Path,
    resourceJarOut: Path,
    benchmarkJarPath: Path,
    classpath: List[Path]
  ): Unit = {
    withTempDirectory { tempDir =>
      val tmpResourceDir = tempDir.resolve("resources")
      val tmpSourceDir = tempDir.resolve("sources")

      tmpResourceDir.toFile.mkdir()
      tmpSourceDir.toFile.mkdir()

      withClassLoader(benchmarkJarPath :: classpath) { isolatedClassLoader =>

        val source: GeneratorSource = generatorType match {
          case AsmGenerator =>
            val generatorSource = new ASMGeneratorSource
            generatorSource.processClasses(collectClassesFromJar(benchmarkJarPath).map(_.toFile).asJavaCollection)
            generatorSource

          case ReflectionGenerator =>
            val generatorSource = new RFGeneratorSource
            generatorSource.processClasses(
              collectClassesFromJar(benchmarkJarPath)
                .flatMap(classByPath(_, isolatedClassLoader))
                .asJavaCollection
            )
            generatorSource
        }

        val generator = new JMHGenerator
        val destination = new FileSystemDestination(tmpResourceDir.toFile, tmpSourceDir.toFile)
        generator.generate(source, destination)
        generator.complete(source, destination)
        if (destination.hasErrors) {
          throw new GenerationException(
            "JHM Benchmark generator failed" +: destination.getErrors.asScala.map(_.toString).toSeq)
        }
      }
      constructJar(sourceJarOut, tmpSourceDir)
      constructJar(resourceJarOut, tmpResourceDir)
    }
  }

  private def classByPath(path: Path, cl: ClassLoader): Option[Class[_]] = {
    val separator = path.getFileSystem.getSeparator
    var s = path.toString
      .stripPrefix(separator)
      .stripSuffix(".class")
      .replace(separator, ".")

    var index = 0
    while (index != -1) {
      s = s.substring(index)
      try {
        return Some(Class.forName(s, false, cl))
      } catch {
        case _: ClassNotFoundException =>
          // ignore and try next one
          index = s.indexOf('.')
      }
    }

    log(s"Failed to find class for path $path")
    None
  }

  private def parseGeneratorType(s: String): GeneratorType = {
    if ("asm".equalsIgnoreCase(s)) {
      AsmGenerator
    } else if ("reflection".equalsIgnoreCase(s)) {
      ReflectionGenerator
    } else {
      throw new IllegalArgumentException(s"unknown generator_type: $s")
    }
  }

  private def log(str: String): Unit = {
    System.err.println(s"JMH benchmark generation: $str")
  }
}
