package io.bazel.rulesscala.utils

import java.io.File
import java.io.IOException
import java.net.URI
import java.util
import java.util.Locale
import javax.tools.DiagnosticCollector
import javax.tools.JavaFileObject
import javax.tools.JavaFileObject.Kind
import javax.tools.SimpleJavaFileObject
import javax.tools.StandardLocation
import javax.tools.ToolProvider

// Modified from
// https://myshittycode.com/2014/02/13/java-programmatically-compile-and-unit-test-generated-java-source-code/
object JavaCompileUtil {
  // in-memory Java file object
  class InMemoryJavaFileObject(val className: String, val contents: String) extends SimpleJavaFileObject(URI.create("string:///" + className.replace('.', '/') + Kind.SOURCE.extension), Kind.SOURCE) {
    @throws[IOException]
    override def getCharContent(ignoreEncodingErrors: Boolean): CharSequence = contents
  }

  /**
   * Compile some java code
   */
  def compile(tmpDir: String, className: String, code: String): Unit = {
    val javaFileObject = new InMemoryJavaFileObject(className, code)
    val compiler = ToolProvider.getSystemJavaCompiler
    val fileManager = compiler.getStandardFileManager(null, null, null)
    val files = util.Arrays.asList(new File(tmpDir))
    fileManager.setLocation(StandardLocation.CLASS_OUTPUT, files)
    val diagnostics = new DiagnosticCollector[JavaFileObject]
    val task = compiler.getTask(null, fileManager, diagnostics, null, null, util.Arrays.asList(javaFileObject))
    val success = task.call
    fileManager.close()
    // If there's a compilation error, display error messages and fail the test
    if (!success) {
      import scala.collection.JavaConverters._
      for (diagnostic <- diagnostics.getDiagnostics.asScala) {
        println("Code: " + diagnostic.getCode)
        println("Kind: " + diagnostic.getKind)
        println("Position: " + diagnostic.getPosition)
        println("Start Position: " + diagnostic.getStartPosition)
        println("End Position: " + diagnostic.getEndPosition)
        println("Source: " + diagnostic.getSource)
        println("Message: " + diagnostic.getMessage(Locale.getDefault))
      }
      throw new Exception("Compilation failed!")
    }
  }
}
