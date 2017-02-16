package scripts

import io.bazel.rules_scala.scrooge_support.{ Compiler, CompilerDefaults }
import io.bazel.rulesscala.jar.JarCreator
import java.io.{ File, FileOutputStream, IOException, PrintStream }
import java.nio.file.attribute.{ BasicFileAttributes, FileTime }
import java.nio.file.{ Files, SimpleFileVisitor, FileVisitResult, Path, Paths }
import scala.collection.mutable.Buffer
import io.bazel.rulesscala.worker.{ GenericWorker, Processor }
import scala.io.Source

object DeleteRecursively extends SimpleFileVisitor[Path] {
  override def visitFile(file: Path, attr: BasicFileAttributes) = {
    Files.delete(file)
    FileVisitResult.CONTINUE
  }

  override def postVisitDirectory(dir: Path, e: IOException) = {
    if (e != null) throw e
    Files.delete(dir)
    FileVisitResult.CONTINUE
  }
}


/**
 * This is our entry point to producing a scala target
 * this can act as one of Bazel's persistant workers.
 */
object ScroogeWorker extends GenericWorker(new ScroogeGenerator) {

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

class ScroogeGenerator extends Processor {
  def deleteDir(path: Path): Unit =
    try Files.walkFileTree(path, DeleteRecursively)
    catch {
      case e: Exception => ()
    }

  def processRequest(args: java.util.List[String]) {
    def getIdx(i: Int): List[String] =
      if (args.size > i) args.get(i).split(':').toList.filter(_.nonEmpty)
      else Nil

    val jarOutput = args.get(0)
    // These are the files whose output we want
    val immediateThriftSrcJars = getIdx(1)
    // These are all of the files to include when generating scrooge
    // Should not include anything in immediateThriftSrcs
    val onlyTransitiveThriftSrcJars = getIdx(2)
    // remote jars are jars that come from another repo, really no different from transitive
    val remoteSrcJars = getIdx(3)

    val tmp = Paths.get(Option(System.getenv("TMPDIR")).getOrElse("/tmp"))
    val scroogeOutput = Files.createTempDirectory(tmp, "scrooge")

    val scrooge = new Compiler

    scrooge.compileJars ++= immediateThriftSrcJars
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

    if (intersect.nonEmpty)
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
