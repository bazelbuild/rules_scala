package io.bazel.rules_scala.scrooge_support
/*
 * Copyright 2011 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License. You may obtain
 * a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * copy-pasta from:
 * https://github.com/twitter/scrooge/blob/develop/scrooge-generator/src/main/scala/com/twitter/scrooge/Compiler.scala
 * to customize the Importers
 *
 * Since scrooge always adds a Importer(".") it would find it from that path by happenstance of how bazel works, but
 * not if there is sandboxing preventing it from seeing it.
 *
 * The solution is make a new Compiler class, don't reuse thrifts, and have better control of how importing works.
 * Doing this I learned that scrooge's zip/jar support is pretty broken and really only works if all imports are
 * considered relative to some fictional root directory (a style done at Twitter, but not really standard for thrift).
 * With my new Compiler, I could only add the importers I want. I made a new importer which is a zip importer that also
 * knows where it is in the zip file. In this way, it could use a thrift jar that itself has internal relative imports
 * (such as our monster thrift jar at Stripe).
 */

import com.twitter.scrooge._
import com.twitter.scrooge.ast.Document
import com.twitter.scrooge.backend.{ GeneratorFactory, ScalaGenerator }
import com.twitter.scrooge.frontend.{ FileParseException, TypeResolver, ThriftParser }
import com.twitter.scrooge.java_generator.ApacheJavaGenerator
import java.io.{ File, FileWriter }
import java.nio.file.Paths
import java.util.jar.{ JarFile, JarEntry }
import java.util.logging.Level
import scala.collection.concurrent.TrieMap

object CompilerDefaults {
  def listJar(_jar: File): List[String] =
    try {
      val files = List.newBuilder[String]
      val jar = new JarFile(_jar)
      val enumEntries = jar.entries()
      while (enumEntries.hasMoreElements) {
        val file = enumEntries.nextElement().asInstanceOf[JarEntry]
        if (!file.isDirectory) {
          files += file.getName
        }
      }
      files.result()
    }
    catch {
      case x: Exception =>
        throw new Exception(s"failed to open: ${_jar}", x)
    }
}

class Compiler(val config: ScroogeConfig) {
  // These are jars we are including, but are not compiling
  val includeJars = config.includePaths
  // these are the jars we want to compile into scala source jars
  val compileJars = config.thriftFiles
  val experimentFlags = config.languageFlags
  var fileMapWriter: scala.Option[FileWriter] = None


  def run() {
    // if --gen-file-map is specified, prepare the map file.
    fileMapWriter = config.fileMapPath.map { path =>
      val file = new File(path)
      val dir = file.getParentFile
      if (dir != null && !dir.exists()) {
        dir.mkdirs()
      }
      if (config.verbose) {
        println("+ Writing file mapping to %s".format(path))
      }
      new FileWriter(file)
    }

    val allJars: List[File] =
      (includeJars ::: compileJars)
        .map { path => (new File(path)).getCanonicalFile }

    val isJava = config.language.equals("java")
    val documentCache = new TrieMap[String, Document]

    // compile
    val allPaths = for {
      jar <- compileJars.iterator
      inputFullPath <- CompilerDefaults.listJar(new File(jar)).iterator
    } yield inputFullPath

    val rootImporter = FocusedZipImporter.forPaths(None, allJars)

    // Here we only should only pass Thrift files to the compiler, other files
    // (e.g. manifest files) are not accepted.
    allPaths.filter(_.endsWith(".thrift")).foreach { inputFullPath =>
      try {
        val inputFile = Paths.get(inputFullPath).getFileName.toString
        val focus = Option((new File(inputFullPath)).getParentFile)
        // allow lookup either focused, or relative to the root of the repo
        val importer = rootImporter.copy(focus = focus) +: rootImporter
        val parser = new ThriftParser(
          importer,
          config.strict,
          defaultOptional = isJava,
          skipIncludes = false,
          documentCache
        )
        parser.logger.setLevel(Level.OFF) // scrooge warns on file names with "/"
        val doc = parser.parseFile(inputFile).mapNamespaces(config.namespaceMappings)

        if (config.verbose) println("+ Compiling %s".format(inputFile))
        val resolvedDoc = TypeResolver()(doc)
        val generator = GeneratorFactory(
          config.language,
          resolvedDoc,
          config.defaultNamespace,
          experimentFlags)

        generator match {
          case g: ScalaGenerator => g.warnOnJavaNamespaceFallback = config.scalaWarnOnJavaNSFallback
          case g: ApacheJavaGenerator => g.serEnumType = config.javaSerEnumType
          case _ => ()
        }

        val generatedFiles = generator(
          config.flags,
          new File(config.destFolder),
          config.dryRun,
          config.genAdapt
        ).map {
          _.getPath
        }
        if (config.verbose) {
          println("+ Generated %s".format(generatedFiles.mkString(", ")))
        }
        fileMapWriter.foreach { w =>
          generatedFiles.foreach { path =>
            w.write(inputFullPath + " -> " + path + "\n")
          }
        }
      } catch {
        case e: Throwable => throw new FileParseException(inputFullPath, e)
      }
    }

    // flush and close the map file
    fileMapWriter.foreach { _.close() }
  }
}
