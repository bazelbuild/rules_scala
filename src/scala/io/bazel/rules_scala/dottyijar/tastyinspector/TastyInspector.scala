package io.bazel.rules_scala.dottyijar.tastyinspector

import io.bazel.rules_scala.dottyijar.tasty.format.{TastyFormat, TastyReader, TastyReferencableInformation}
import io.bazel.rules_scala.dottyijar.tasty.{Tasty, TastyNameTable}
import java.nio.file.{Files, Paths}
import scala.collection.mutable
import scala.jdk.CollectionConverters.*
import scala.sys.process.*
import scala.util.Try

object TastyInspector {
  private val maximumLineLength = 120
  private val prettyPrintCache = mutable.Map[(Any, Int), String]()
  private def getIndentation(depth: Int): String = "  " * depth
  private def prettyPrintTasty(tasty: Tasty): String = prettyPrintTastyValue(tasty, depth = 0)
  private def prettyPrintTastyProductLike(prefix: String, elements: => Iterator[Any], depth: Int): String = {
    val indentation = getIndentation(depth)
    val singleLineJoinedElements = elements.map(prettyPrintTastyValue(_, depth = 0)).mkString(", ")
    val singleLine = s"$indentation$prefix($singleLineJoinedElements)"

    if (singleLine.length <= maximumLineLength) {
      singleLine
    } else {
      val lines = elements.map(element => s"${prettyPrintTastyValue(element, depth = depth + 1)},\n").mkString

      s"$indentation$prefix(\n$lines$indentation)"
    }
  }

  private def prettyPrintTastyValue(value: Any, depth: Int): String = prettyPrintCache.getOrElseUpdate(
    (value, depth),
    value match {
      case iterable: Iterable[?] =>
        prettyPrintTastyProductLike(
          iterable match {
            case _: List[?] => "List"
            case _: Vector[?] => "Vector"
            case _ => iterable.getClass.getSimpleName
          },
          iterable.iterator,
          depth,
        )

      /**
       * [[TastyNameTable]] is the only type that overrides `toString`.
       */
      case product: Product if !product.isInstanceOf[TastyNameTable] =>
        if (product.productArity == 0) {
          s"${getIndentation(depth)}${product.productPrefix}"
        } else {
          prettyPrintTastyProductLike(product.productPrefix, product.productIterator, depth)
        }

      case _ => value.toString.split('\n').view.map(line => s"${getIndentation(depth)}$line").mkString("\n")
    },
  )

  def main(arguments: Array[String]): Unit = (
    for {
      argument <- arguments.headOption.toRight("Please provide a path to a `.scala` file.\n")
      tastyPath <-
        if (argument.endsWith(".tasty")) {
          Right(Paths.get(argument))
        } else {
          val outputDirectory = Files.createTempDirectory("tasty-inspector")
          val compilerReturnCode = List(
            "src/scala/io/bazel/rules_scala/dottyijar/tastyinspector/compiler",
            "-d",
            outputDirectory.toString,
            "-usejavacp",
            argument,
          ).!

          if (compilerReturnCode == 0) {
            val outputtedFileStream = Files.walk(outputDirectory)

            try {
              val outputtedFiles = outputtedFileStream.iterator.asScala
                .filter(path => path.toFile.isFile && path.toString.endsWith(".tasty"))
                .toList

              outputtedFiles match {
                case List(path) => Right(path)
                case Nil => Left("The compiler didn't produce any `.tasty` files.\n")
                case _ => Left(s"The compiler produced multiple `.tasty` files: ${outputtedFiles.mkString(", ")}\n")
              }
            } finally {
              outputtedFileStream.close()
            }
          } else {
            Left("")
          }
        }
    } yield tastyPath
  ) match {
    case Left(errorMessage) =>
      println(errorMessage)

      sys.exit(1)

    case Right(tastyPath) =>
      val tasty = Tasty.read(Files.readAllBytes(tastyPath))

      println(prettyPrintTasty(tasty))
  }
}
