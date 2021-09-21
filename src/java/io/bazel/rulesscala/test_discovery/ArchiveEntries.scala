package io.bazel.rulesscala.test_discovery

import java.io.{File, FileInputStream}
import java.util.jar.{JarEntry, JarInputStream}

object ArchiveEntries {
  def listClassFiles(file: File): Stream[String] = {
    val allEntries = if (file.isDirectory)
      directoryEntries(file).map(_.stripPrefix(file.toString).stripPrefix("/"))
    else
      jarEntries(new JarInputStream(new FileInputStream(file)))

    allEntries.filter(_.endsWith(".class"))
  }

  private def getJarEntryOrCloseStream(jarInputStream: JarInputStream): Option[JarEntry] = {
    val entry = Option(jarInputStream.getNextJarEntry)

    if (entry.isEmpty)
      jarInputStream.close()

    entry
  }

  private def jarEntries(jarInputStream: JarInputStream): Stream[String] =
    Stream.continually(getJarEntryOrCloseStream(jarInputStream))
      .takeWhile(_.nonEmpty)
      .flatten
      .map(_.getName)

  private def directoryEntries(file: File): Stream[String] =
    file.toString #:: (file.listFiles match {
      case null => Stream.empty
      case files => files.toStream.flatMap(directoryEntries)
    })
}
