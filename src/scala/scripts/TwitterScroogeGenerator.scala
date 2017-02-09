package scripts

import io.bazel.rules_scala.scrooge_support.{ Compiler, CompilerDefaults }
import io.bazel.rulesscala.jar.JarCreator
import java.io.{ File, FileOutputStream, IOException }
import java.nio.file.attribute.{ BasicFileAttributes, FileTime }
import java.nio.file.{ Files, SimpleFileVisitor, FileVisitResult, Path, Paths }
import scala.collection.mutable.Buffer
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

object ScroogeGenerator {
  def deleteDir(path: Path) {
    try {
      Files.walkFileTree(path, DeleteRecursively)
    } catch {
      case e: Exception =>
    }
  }


  def readLines(path: Path): List[String] =
    Source.fromFile(path.toString).getLines.toSet.toList.sorted

  def main(args: Array[String]) {
    if (args.length != 4) sys.error("Need to ensure enough arguments! " +
      "Required 4 arguments: onlyTransitiveThriftSrcs immediateThriftSrcs " +
      "jarOutput remoteJarsFile. Received: " + args)

    val onlyTransitiveThriftSrcsFile = Paths.get(args(0))
    val immediateThriftSrcsFile = Paths.get(args(1))
    val jarOutput = args(2)
    val remoteJarsFile = Paths.get(args(3))

    val tmp = Paths.get(Option(System.getenv("TMPDIR")).getOrElse("/tmp"))
    val scroogeOutput = Files.createTempDirectory(tmp, "scrooge")

    // These are all of the files to include when generating scrooge
    // Should not include anything in immediateThriftSrcs
    val onlyTransitiveThriftSrcJars = readLines(onlyTransitiveThriftSrcsFile)

    // These are the files whose output we want
    val immediateThriftSrcJars = readLines(immediateThriftSrcsFile)
    // remote jars are jars that come from another repo, really no different from transitive
    val remoteSrcJars = readLines(remoteJarsFile)

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
