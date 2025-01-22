package io.bazel.rules_scala.dottyijar

import io.bazel.rules_scala.dottyijar.tasty.Tasty
import io.bazel.rules_scala.dottyijar.tasty.format.{TastyFormat, TastyReader, TastyWriter}
import java.io.FileOutputStream
import java.nio.file.{Path, Paths}
import java.nio.file.attribute.FileTime
import java.util.zip.{ZipEntry, ZipFile, ZipOutputStream}
import scala.jdk.CollectionConverters.*

object DottyIjar {
  private def writeInterfaceJar(inputJar: ZipFile, outputStream: ZipOutputStream): Unit = {
    def copyEntryWithContent(entry: ZipEntry, content: Array[Byte]): Unit = {
      val newEntry = new ZipEntry(entry.getName)

      newEntry.setCreationTime(FileTime.fromMillis(0))
      newEntry.setLastAccessTime(FileTime.fromMillis(0))
      newEntry.setLastModifiedTime(FileTime.fromMillis(0))

      outputStream.putNextEntry(newEntry)
      outputStream.write(content, 0, content.length)
    }

    def copyEntry(entry: ZipEntry): Unit = copyEntryWithContent(entry, inputJar.getInputStream(entry).readAllBytes())

    outputStream.setComment(inputJar.getComment)
    outputStream.setLevel(0)

    val entryNames = inputJar.entries.asScala.map(_.getName).toSet

    inputJar.entries.asScala.foreach {
      case entry if entry.getName.startsWith("META-INF/") => copyEntry(entry)
      case entry if entry.getName.endsWith(".class") =>
        val i = entry.getName.lastIndexOf('/')
        val directory = entry.getName.slice(0, i)
        val filename = entry.getName.slice(i + 1, entry.getName.length)
        val j = filename.indexOf("$")
        val tastyFileBaseName = if (j == -1) filename.stripSuffix(".class") else filename.slice(0, j)

        if (!entryNames(s"$directory/$tastyFileBaseName.tasty")) {
          copyEntry(entry)
        }

      case entry if entry.getName.endsWith(".tasty") =>
        val content = inputJar.getInputStream(entry).readAllBytes()
        val updatedContent = TastyUpdater.updateTastyFile(content)

        copyEntryWithContent(entry, updatedContent)

      case entry => copyEntry(entry)
    }
  }

  def main(arguments: Array[String]): Unit = Arguments
    .parseArguments(arguments)
    .fold(
      println,
      arguments => {
        val inputJar = new ZipFile(arguments.inputPath.toFile)

        try {
          val outputStream = new ZipOutputStream(new FileOutputStream(arguments.outputPath.toFile))

          try {
            writeInterfaceJar(inputJar, outputStream)
          } finally {
            outputStream.close()
          }
        } finally {
          inputJar.close()
        }
      },
    )
}

private case class Arguments(inputPath: Path, outputPath: Path)

object Arguments {
  def parseArguments(arguments: Array[String]): Either[String, Arguments] = arguments
    .foldLeft[Either[String, UnvalidatedArguments]](Right(UnvalidatedArguments())) {
      case (unvalidatedArguments, argument) =>
        unvalidatedArguments.flatMap { unvalidatedArguments =>
          argument match {
            case "-h" | "--help" =>
              Left(
                """dottyijar removes information from Scala 3 JARs that aren't needed for compilation.
                |
                |Usage:
                |  dottyijar <input> <output>
                |  dottyijar -h | --help
                |
                |Options:
                |  -h --help  Show this screen.""".stripMargin,
              )

            case _ =>
              lazy val path = Paths.get(argument)

              if (unvalidatedArguments.inputPath.isEmpty) {
                Right(unvalidatedArguments.copy(inputPath = Some(path)))
              } else if (unvalidatedArguments.outputPath.isEmpty) {
                Right(unvalidatedArguments.copy(outputPath = Some(path)))
              } else {
                Left(s"Unexpected argument: $argument")
              }
          }
        }
    }
    .flatMap(_.validate)
}

private case class UnvalidatedArguments(inputPath: Option[Path] = None, outputPath: Option[Path] = None) {
  def validate: Either[String, Arguments] = (
    for {
      inputPath <- inputPath
      outputPath <- outputPath
    } yield Arguments(inputPath, outputPath)
  ).toRight("Please provide paths to the input and output JARs.")
}
