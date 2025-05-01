package io.bazel.rulesscala.dependencyanalyzer

import org.scalatest.funsuite.AnyFunSuite
import io.bazel.rulesscala.utils.TestUtil

class CompileTest extends AnyFunSuite {

  test("Util compiles valid code") {
    val scalaCode = "class Foo {  }"
    val diagnostics = TestUtil.runCompiler(scalaCode)

    assert(diagnostics.isEmpty, "No messages must be reported when valid code is compiled")
  }

  test("Util returns errors on invalid code") {
    val scalaCode = "!@#"
    val diagnostics = TestUtil.runCompiler(scalaCode)

    assert(
      diagnostics.exists(_.isInstanceOf[TestUtil.Diagnostic.Error]),
      "Error must be reported when valid code is compiled"
    )
  }
}