package scripts

import com.twitter.scrooge.Compiler

import scala.collection.mutable.Buffer
import scala.io.Source

import java.io.{ File, FileOutputStream, IOException }
import java.nio.file.{ Files, SimpleFileVisitor, FileVisitResult, Path, Paths }
import java.nio.file.attribute.{ BasicFileAttributes, FileTime }
import java.util.jar.{ JarEntry, JarFile, JarOutputStream }

object FinalJarCreator {
  val gm = """(\S+) -> (\S+)""".r

  def apply(dest: Path, owned: Set[String], genFileMap: Path, scroogeDir: Path) {
    val genmap = Source.fromFile(genFileMap.toString)
      .getLines
      .foldLeft(Map.empty[String, Set[String]]) { case (m, gm(thrift, gen)) =>
        m.+((thrift, m.getOrElse(thrift, Set.empty[String]) + gen))
      }
    val shouldMove =
      owned.foldLeft(Set.empty[String]) { (s, n) =>
        genmap.get(n).fold(s) { s ++ _ }
      }.map { Paths.get(_).normalize }
    val jar = new JarOutputStream(new FileOutputStream(dest.toFile))
    Files.walkFileTree(
      scroogeDir,
      FinalJarCreator(scroogeDir, jar, shouldMove)
    )
    jar.close()
  }
}
case class FinalJarCreator(_baseDir: Path, jar: JarOutputStream, shouldMove: Set[Path]) extends SimpleFileVisitor[Path] {
  val baseDir = _baseDir.normalize

  // We return the path of the file to add to the jar
  def shouldVisitFile(file: Path): Option[Path] =
    if (shouldMove.contains(file)) Some(baseDir.relativize(file))
    else None

  override def visitFile(file: Path, attr: BasicFileAttributes) = {
    shouldVisitFile(file).foreach { _file =>
      val entry = new JarEntry(_file.toString)
      entry.setTime(198001010000L)
      jar.putNextEntry(entry)
      Files.copy(file, jar)
    }
    FileVisitResult.CONTINUE
  }
}

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

case class ForeachFile(f: Path => Unit) extends SimpleFileVisitor[Path] {
  override def visitFile(file: Path, attr: BasicFileAttributes) = {
    f(file)
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

  def listJar(_jar: Path): List[String] = {
    val files = List.newBuilder[String]
    val jar = new JarFile(_jar.toFile)
    val enumEntries = jar.entries()
    while (enumEntries.hasMoreElements) {
      val file = enumEntries.nextElement().asInstanceOf[JarEntry]
      if (!file.isDirectory) {
        files += file.getName
      }
    }
    files.result()
  }

  def readLinesAsPaths(path: Path): Set[Path] =
    Source.fromFile(path.toString).getLines.map(Paths.get(_)).toSet

  def main(args: Array[String]) {
    if (args.length != 4) sys.error("Need to ensure enough arguments! " +
      "Required 4 arguments: onlyTransitiveThriftSrcs immediateThriftSrcs " +
      "jarOutput remoteJarsFile. Received: " + args)

    val onlyTransitiveThriftSrcsFile = Paths.get(args(0))
    val immediateThriftSrcsFile = Paths.get(args(1))
    val jarOutput = Paths.get(args(2))
    val remoteJarsFile = Paths.get(args(3))

    val tmp = Paths.get(Option(System.getenv("TMPDIR")).getOrElse("/tmp"))
    val scroogeOutput = Files.createTempDirectory(tmp, "scrooge")

    // These are all of the files to include when generating scrooge
    // Should not include anything in immediateThriftSrcs
    val onlyTransitiveThriftSrcJars = readLinesAsPaths(onlyTransitiveThriftSrcsFile)

    // These are the files whose output we want
    val immediateThriftSrcJars = readLinesAsPaths(immediateThriftSrcsFile)

    val genFileMap = scroogeOutput.resolve("gen-file-map.txt")

    val scrooge = new Compiler

    // these are the ones we are actually generating
    def allFilesInZips(i: Iterable[Path]): Set[String] =
      i.flatMap(listJar(_)).toSet

    val immediateThriftSrcs = allFilesInZips(immediateThriftSrcJars)
    immediateThriftSrcs.foreach { scrooge.thriftFiles += _ }
    immediateThriftSrcJars.foreach { path => scrooge.includePaths += path.toString }
    onlyTransitiveThriftSrcJars.foreach { path => scrooge.includePaths += path.toString }

    // should check that we have no overlap in any of the types
    // we are just going to try extracting EVERYTHING to the same tree, and we will just error if there
    // are more than one.
    val intersect = allFilesInZips(onlyTransitiveThriftSrcJars).intersect(immediateThriftSrcs)
    if (intersect.nonEmpty)
      sys.error("onlyTransitiveThriftSrcs and immediateThriftSrcs should " +
        s"have not intersection, found: ${intersect.mkString(",")}")

    val remoteSrcJars = readLinesAsPaths(remoteJarsFile)
    remoteSrcJars.foreach { path => scrooge.includePaths += path.toString }

    val dirsToDelete = Set(scroogeOutput)
    scrooge.destFolder = scroogeOutput.toString
    scrooge.fileMapPath = Some(genFileMap.toString)
    //TODO we should make this configurable
    scrooge.strict = false
    scrooge.run()

    FinalJarCreator(jarOutput, immediateThriftSrcs, genFileMap, scroogeOutput)

    // Clean it out to be idempotent
    dirsToDelete.foreach { deleteDir(_) }
  }
}
