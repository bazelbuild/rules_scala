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

  def apply(dest: String, owned: Set[String], genFileMap: String, scroogeDir: String) {
    val genmap = Source.fromFile(genFileMap)
      .getLines
      .foldLeft(Map.empty[String, Set[String]]) { case (m, gm(thrift, gen)) =>
        m.+((thrift, m.getOrElse(thrift, Set.empty[String]) + gen))
      }
    val shouldMove =
      owned.foldLeft(Set.empty[String]) { (s, n) =>
        genmap.get(n).fold(s) { s ++ _ }
      }.map { Paths.get(_).normalize }
    val jar = new JarOutputStream(new FileOutputStream(dest))
    Files.walkFileTree(
      Paths.get(scroogeDir),
      FinalJarCreator(scroogeDir, jar, shouldMove)
    )
    jar.close()
  }
}
case class FinalJarCreator(_baseDir: String, jar: JarOutputStream, shouldMove: Set[Path]) extends SimpleFileVisitor[Path] {
  val baseDir = Paths.get(_baseDir).normalize

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

//TODO deal with errors etc
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

//TODO add logging?
object ScroogeGenerator {
  def deleteDir(path: Path) {
    try {
      Files.walkFileTree(path, DeleteRecursively)
    } catch {
      case e: Exception => //TODO LOG
    }
  }

  def extractJarTo(_jar: String, _dest: String): List[Path] = {
    val files = Buffer[Path]()
    //TODO add to it, error if duplicate!
    val jar = new JarFile(_jar)
    val enumEntries = jar.entries()
    while (enumEntries.hasMoreElements) {
      val file = enumEntries.nextElement().asInstanceOf[JarEntry]
      val f = new File(_dest, file.getName) //TODO pathify this
      if (file.isDirectory()) f.mkdir()
      else {
        val path = Paths.get(f.toURI)

        val is = jar.getInputStream(file)
        try {
          Files.copy(is, path) // Will error out if path already exists
        } finally {
          is.close()
        }

        files += path
      }
    }
    files.toList
  }

  //TODO add logging that can be turned on/off?
  def main(args: Array[String]) {
    if (args.length < 4) sys.error("Need to ensure enough arguments! " +
      "Required 3 arguments: onlyTransitiveThriftSrcs immediateThriftSrcs " +
      "jarOutput remoteJarsFile. Received: " + args.mkString(","))

    val onlyTransitiveThriftSrcsFile = args(0)
    val immediateThriftSrcsFile = args(1)
    val jarOutput = args(2)
    val remoteJarsFile = args(3)

    val tmp = Paths.get(Option(System.getenv("TMPDIR")).getOrElse("/tmp"))
    val scroogeOutput = Files.createTempDirectory(tmp, "scrooge").toString

    // These are all of the files to include when generating scrooge
    // Should not include anything in immediateThriftSrcs
    val onlyTransitiveThriftSrcJars =
      Source.fromFile(onlyTransitiveThriftSrcsFile).getLines.toSet

    // These are the files whose output we want
    val immediateThriftSrcJars =
      Source.fromFile(immediateThriftSrcsFile).getLines.toSet

    val genFileMap = s"$scroogeOutput/gen-file-map.txt"

    val scrooge = new Compiler

    // we need to extract into the same tree, as that is the only way to get relative imports between them working..
    // AS SUCH, we are just going to try extracting EVERYTHING to the same tree, and we will just error if there
    // are more than one.
    val _tmp =  Files.createTempDirectory(tmp, "jar")
    // This will only be meaningful if they have absolute_prefix set
    scrooge.includePaths += _tmp.toString

    //TODO we should probably just make everything Paths instead of strings
    def extract(jars: Set[String]): Set[String] =
      jars.flatMap { jar =>
        val files = extractJarTo(jar, _tmp.toString)
        files.foreach { scrooge.includePaths += _.toString }
        files.map(_.toString)
      }

    val immediateThriftSrcs = extract(immediateThriftSrcJars)

    immediateThriftSrcs.foreach { scrooge.thriftFiles += _ }

    val onlyTransitiveThriftSrcs = extract(onlyTransitiveThriftSrcJars)

    val intersect = onlyTransitiveThriftSrcs.intersect(immediateThriftSrcs)

    if (intersect.nonEmpty)
      sys.error("onlyTransitiveThriftSrcs and immediateThriftSrcs should " +
        s"have not intersection, found: ${intersect.mkString(",")}")

    //TODO WE NEED TO TEST THIS!!
    val remoteSrcJars = Source.fromFile(remoteJarsFile).getLines.toSet
    extract(remoteSrcJars)

    val dirsToDelete =
      Set(
        immediateThriftSrcsFile,
        onlyTransitiveThriftSrcsFile,
        scroogeOutput,
        remoteJarsFile,
        _tmp.toString
      ).map(Paths.get(_))

    scrooge.destFolder = scroogeOutput
    scrooge.fileMapPath = Some(genFileMap)
    //TODO NOOOOOOOooooOOO
    scrooge.strict = false
    scrooge.run()

    FinalJarCreator(jarOutput, immediateThriftSrcs, genFileMap, scroogeOutput)

    // Clean it out to be idempotent
    dirsToDelete.foreach { deleteDir(_) }
  }
}

/**

This is what currently exists, and what we want to transfer over

What we can't get around is making the input files available (to avoid length issues)
- file 1: [f.path for f in transitive_thrift_srcs]
- file 2: [f.path for f in immediate_thrift_srcs]
- invoke it with those paths

  cmd = """
rm -rf {out}_tmp
set -e
{java} -classpath "{jars}" com.twitter.scrooge.Main -d {out}_tmp --gen-file-map {gen_file_map} $@
find {out}_tmp -exec touch -t 198001010000 {{}} \;
touch -t 198001010000 {manifest}
{jar} cmf {manifest} {out} -C {out}_tmp .
rm -rf {out}_tmp
""".format(
    java=ctx.file._java.path,
    out=ctx.outputs.srcjar_polluted.path,
    manifest=ctx.outputs.manifest.path,
    jar=ctx.file._jar.path,
    jars=":".join([f.path for f in cjars]),
    gen_file_map=ctx.outputs.gen_file_map.path,
  )


ctx.action(
    inputs=list(transitive_thrift_srcs) +
        list(transitive_owned_srcs) +
        cjars +
        ctx.files._jdk +
        ctx.files._scalasdk +
        [ctx.outputs.manifest, ctx.file._jar],
    outputs=[ctx.outputs.srcjar_polluted, ctx.outputs.gen_file_map],
    command=cmd,
    progress_message="scrooge generation %s" % ctx.label,
    # Since we have access to the graph, we don't have to muck with the
    # thrift_library tar, we can just use the sources directly
    arguments=[f.path for f in transitive_thrift_srcs],
  )

  pluck_cmd="""
rm -rf {out}_tmp_polluted
rm -rf {out}_tmp
set -e
mkdir {out}_tmp_polluted
mkdir {out}_tmp
unzip -o {polluted} -d {out}_tmp_polluted 2>/dev/null
touch -t 198001010000 {manifest}
touch {out}_tmp_polluted/gen_pluck_cmd
{pluck} {jar} {manifest} {out} {out}_tmp_polluted/gen_pluck_cmd {out}_tmp_polluted {genmap} {include_base} {pluck_base} $@
bash {out}_tmp_polluted/gen_pluck_cmd
rm -rf {out}_tmp_polluted
rm -rf {out}_tmp
""".format(
    pluck = ctx.executable._pluck_scrooge.path,
    polluted = ctx.outputs.srcjar_polluted.path,
    genmap = ctx.outputs.gen_file_map.path,
    out = ctx.outputs.srcjar.path,
    manifest = ctx.outputs.manifest.path,
    jar = ctx.file._jar.path,
    include_base = ctx.outputs.srcjar_polluted.path + "_tmp",
    pluck_base = ctx.outputs.srcjar.path + "_tmp_polluted",
  )

  ctx.action(
    inputs = ctx.files._pluck_scrooge + [
      ctx.outputs.srcjar_polluted,
      ctx.outputs.gen_file_map,
      ctx.outputs.manifest,
      ctx.file._jar,
    ] +
    list(ctx.attr._pluck_scrooge.default_runfiles.files) +
    list(ctx.attr._pluck_scrooge.data_runfiles.files),
    outputs = [ctx.outputs.srcjar],
    command = pluck_cmd,
    progress_message = "plucking owned scrooge files %s" % ctx.label,
    arguments = [f.path for f in immediate_thrift_srcs],
  )
**/