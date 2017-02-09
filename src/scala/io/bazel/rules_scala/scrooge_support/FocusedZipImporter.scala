package io.bazel.rules_scala.scrooge_support

import com.twitter.scrooge.frontend.{ FileContents, Importer }

import java.io.File
import java.util.zip.{ZipFile, ZipEntry}
import scala.io.Source

object FocusedZipImporter {
  def forPaths(focus: Option[File], zips: List[File]): FocusedZipImporter =
    FocusedZipImporter(focus, zips, zips.map(new ZipFile(_)))
}

/**
 * A FocusedZipImporter is just a ZipImporter that has a current directory
 * associated with it (the focus)
 */
case class FocusedZipImporter(focus: Option[File], zips: List[File], zipFiles: List[ZipFile]) extends Importer {
  override lazy val canonicalPaths = zips.map(_.getCanonicalPath)

  private def toZipEntryPath(n: String): String = focus match {
    case None => n
    case Some(f) =>
      @annotation.tailrec
      def loop(leftPart: File, p: List[String]): File = p match {
        case Nil => leftPart
        case ".." :: tail =>
          val parent = leftPart.getParentFile
          if (parent == null) sys.error(s"invalid path: $n with focus: $focus for zips: $zips")
          else loop(parent, tail)
        case "." :: tail => loop(leftPart, tail)
        case child :: tail => loop(new File(leftPart, child), tail)
      }
      val parts = n.split("/", -1).toList
      val newPath = loop(f, parts).toString
      if (parts(0) == File.pathSeparatorChar) newPath.substring(1)
      else newPath
  }

  private def resolve(filename: String): Option[(ZipEntry, ZipFile, FocusedZipImporter)] = {
    val fullPath = toZipEntryPath(filename)
    zipFiles
      .iterator
      .map { z => Option(z.getEntry(fullPath)).map((_, z)) }
      .collectFirst { case Some(s) => s }
      .map { case (ze, z) =>
        // prepare the new focus for this file:
        val newF = Option(new File(fullPath).getParentFile)
        (ze, z, copy(focus = newF))
      }
  }

  private val maxLastMod = zips.map(_.lastModified).reduceOption(_ max _)
  // uses the lastModified time of the zip/jar file
  def lastModified(filename: String): Option[Long] =
    resolve(filename).flatMap(_ => maxLastMod)

  def apply(filename: String): Option[FileContents] =
    resolve(filename) map { case (entry, zipFile, importer) =>
      FileContents(importer, Source.fromInputStream(zipFile.getInputStream(entry), "UTF-8").mkString, Some(entry.getName))
    }

  private[this] def canResolve(filename: String): Boolean = resolve(filename).isDefined

  override def getResolvedPath(filename: String): Option[String] =
    resolve(filename).map { case (_, zf, _) =>
      new File(zf.getName, toZipEntryPath(filename)).getCanonicalPath
    }
}
