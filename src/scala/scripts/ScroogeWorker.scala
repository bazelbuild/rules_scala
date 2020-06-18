package scripts

import io.bazel.rules_scala.scrooge_support.{ Compiler, CompilerDefaults }
import com.twitter.scrooge.backend.WithFinagle
import io.bazel.rulesscala.jar.JarCreator
import io.bazel.rulesscala.io_utils.DeleteRecursively
import java.io.{ File, PrintStream }
import java.nio.file.{ Files, Path, Paths }
import scala.collection.mutable.Buffer
import io.bazel.rulesscala.worker.Worker
import scala.io.Source

object ScroogeWorker extends Worker.Interface {

  def main(args: Array[String]): Unit = Worker.workerMain(args, ScroogeWorker)

  def deleteDir(path: Path): Unit =
    try DeleteRecursively.run(path)
    catch {
      case e: Exception => ()
    }

  def work(args: Array[String]) {
    def getIdx(i: Int): List[String] = {
      if (args.size > i) {
        // bazel worker arguments cannot be empty so we pad to ensure non-empty
        // and drop it off on the other side
        // https://github.com/bazelbuild/bazel/issues/3329
        val workerArgPadLen = 1 // workerArgPadLen == "_".length
        args(i)
          .drop(workerArgPadLen)
          .split(':')
          .toList
          .filter(_.nonEmpty)
      }
      else Nil
    }

    val jarOutput = args(0)
    // These are the files whose output we want
    val immediateThriftSrcJars = getIdx(1)
    // These are all of the files to include when generating scrooge
    // Should not include anything in immediateThriftSrcs
    val onlyTransitiveThriftSrcJars = getIdx(2)
    // remote jars are jars that come from another repo, really no different from transitive
    val remoteSrcJars = getIdx(3)

    // These are remote JARs where we want to export the generated class files
    // built from the Thrifts in the JAR. This is the remote JAR version o
    // immediateThriftSrcJars.
    val remoteSelfThriftSources = getIdx(4)

    // Further configuration options for scrooge.
    val additionalFlags = getIdx(5)

    val tmp = Paths.get(Option(System.getProperty("java.io.tmpdir")).getOrElse("/tmp"))
    val scroogeOutput = Files.createTempDirectory(tmp, "scrooge")

    val scrooge = new Compiler

    additionalFlags.foreach {
      case "--with-finagle" => {
        scrooge.flags += WithFinagle
      }
      case f if f.startsWith("--language=") => {
        scrooge.language = f.split("=")(1)
      }
    }

    scrooge.compileJars ++= immediateThriftSrcJars
    scrooge.compileJars ++= remoteSelfThriftSources
    scrooge.includeJars ++= onlyTransitiveThriftSrcJars
    scrooge.includeJars ++= remoteSrcJars

    // should check that we have no overlap in any of the types
    // we are just going to try extracting EVERYTHING to the same tree, and we will just error if there
    // are more than one.
    def allFilesInZips(fs: List[String]): Set[String] =
      fs.flatMap { f => CompilerDefaults.listJar(new File(f)) }.toSet

    val immediateThriftSrcs = allFilesInZips(immediateThriftSrcJars)
    val intersect = allFilesInZips(onlyTransitiveThriftSrcJars)
      .intersect(immediateThriftSrcs)

    if (intersect.iterator.filter(_.endsWith(".thrift")).nonEmpty)
      sys.error("onlyTransitiveThriftSrcs and immediateThriftSrcs should " +
        s"have not intersection, found: ${intersect.mkString(",")}")

    val dirsToDelete = Set(scroogeOutput)
    scrooge.destFolder = scroogeOutput.toString
    //TODO we should make this configurable
    scrooge.strict = false
    scrooge.run()

    JarCreator.buildJar(Array(jarOutput, scroogeOutput.toString))

    // Clean it out to be idempotent
    dirsToDelete.foreach { deleteDir(_) }
  }
}
