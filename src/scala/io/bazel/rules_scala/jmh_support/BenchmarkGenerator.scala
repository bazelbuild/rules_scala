package io.bazel.rules_scala.jmh_support

import java.net.URLClassLoader

import scala.annotation.tailrec
import scala.collection.JavaConverters._

import org.openjdk.jmh.generators.core.{ BenchmarkGenerator => JMHGenerator, FileSystemDestination }
import org.openjdk.jmh.generators.asm.ASMGeneratorSource
import org.openjdk.jmh.runner.{ Runner, RunnerException }
import org.openjdk.jmh.runner.options.{ Options, OptionsBuilder }

import java.nio.file.{Files, FileSystems, Path}


object BenchmarkGenerator {
  case class JmhGeneratedSources(sources: Seq[Path], resources: Seq[Path])

  def main(argv: Array[String]): Unit = {
    val classPath = System.getProperty("java.class.path").split(':').map {s =>
      FileSystems.getDefault.getPath(s)
    }
    val fs = FileSystems.getDefault

    val outDir = fs.getPath(argv(1))
    val srcDir = outDir.resolve("sources")
    if (!srcDir.toFile.isDirectory) { srcDir.toFile.mkdirs() }
    val resourceDir = outDir.resolve("resources")
    if (!resourceDir.toFile.isDirectory) { resourceDir.toFile.mkdirs() }

    val generated = generateJmhBenchmark(
      srcDir,
      resourceDir,
      List(fs.getPath(argv(0)).getParent),
      classPath
    )
  }

  private def listFiles(dir: Path): List[Path] = {
    val stream = Files.newDirectoryStream(dir)
    stream.asScala.toList
  }

  private def listFilesRecursively(root: Path)(pred: Path => Boolean): List[Path] = {
    def loop(fs0: List[Path], files: List[Path]): List[Path] = fs0 match {
      case f :: fs if f.toFile.isDirectory => loop(fs ++ listFiles(f), files)
      case f :: fs if pred(f) => loop(fs, f :: files)
      case _ :: fs => loop(fs, files)
      case Nil => files.reverse
    }

    loop(root :: Nil, Nil)
  }

  private def collectClasses(root: Path): List[Path] =
    listFilesRecursively(root) { path =>
      path.getFileName.toString.endsWith(".class")
    }

  private def createDirectories(p: Path): Unit = {
    def missingParents(path: Path): List[Path] = {
      if (path == null || path.toFile.exists() || path.toFile.isDirectory) {
        Nil
      } else {
        path :: missingParents(path.getParent)
      }
    }
    missingParents(p.getParent).reverse.foreach { d =>
      if (!d.toFile.mkdir()) {
        sys.error(s"Failed to create directory $d")
      }
    }
  }

  private def move(from: Path, to: Path): List[Path] =
    listFilesRecursively(from)(_ => true).map { src =>
      val tail = from.relativize(src)
      val dest = to.resolve(tail)
      createDirectories(dest)
      Files.move(src, dest)
      dest
    }

  // Courtesy of Doug Tangren (https://groups.google.com/forum/#!topic/simple-build-tool/CYeLHcJjHyA)
  private def withClassLoader[A](cp: Seq[Path])(f: => A): A = {
    val originalLoader = Thread.currentThread.getContextClassLoader
    val jmhLoader = classOf[JMHGenerator].getClassLoader
    val classLoader = new URLClassLoader(cp.map(_.toUri.toURL).toArray, jmhLoader)
    try {
      Thread.currentThread.setContextClassLoader(classLoader)
      f
    } finally {
      Thread.currentThread.setContextClassLoader(originalLoader)
    }
  }

  private def withTempDirectory[A](f: Path => A): A = {
    val baseDir = System.getProperty("java.io.tmpdir")
    val tempDir = Files.createTempDirectory("jmh_benchmark_generator")
    try {
      f(tempDir)
    } finally {
      listFilesRecursively(tempDir)(_ => true).reverse.foreach {file =>
        log(s"would delete $file")
      }
    }
  }

  private def generateJmhBenchmark(
    sourceDir: Path,
    resourceDir: Path,
    benchmarkClasspath: Seq[Path],
    fullClasspath: Seq[Path]
  ): JmhGeneratedSources = {
    withTempDirectory { tempDir =>
      val tmpResourceDir = tempDir.resolve("resources")
      val tmpSourceDir = tempDir.resolve("sources")

      tmpResourceDir.toFile.mkdir()
      tmpSourceDir.toFile.mkdir()

      withClassLoader(benchmarkClasspath ++ fullClasspath) {
        val source = new ASMGeneratorSource
        val destination = new FileSystemDestination(tmpResourceDir.toFile, tmpSourceDir.toFile)
        val generator = new JMHGenerator

        val classes = benchmarkClasspath.flatMap(f => collectClasses(f)).map(_.toFile)
        source.processClasses(classes.asJava)
        generator.generate(source, destination)
        generator.complete(source, destination)
        if (destination.hasErrors) {
          log("JMH Benchmark generator failed")
          for (e <- destination.getErrors.asScala) {
            log(e.toString)
          }
        }
      }

      JmhGeneratedSources(move(tmpSourceDir, sourceDir), move(tmpResourceDir, resourceDir))
    }
  }

  private def log(str: String): Unit = {
    System.err.println(s"JMH benchmark generation: $str")
  }
}
