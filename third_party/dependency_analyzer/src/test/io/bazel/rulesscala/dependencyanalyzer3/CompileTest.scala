package io.bazel.rulesscala.dependencyanalyzer

import org.scalatest.funsuite.AnyFunSuite
import io.bazel.rulesscala.utils.Scala3CompilerUtils
import io.bazel.rulesscala.utils.Scala3CompilerUtils._

class CompileTest extends AnyFunSuite {

    test("Util compiles valid code") {
        val scalaCode = "class Foo {  }"
        val result = Scala3CompilerUtils.runCompiler(scalaCode)

        assert(result.isSuccess, "No messages must be reported when valid code is compiled")
    }

    test("Util returns errors on invalid code") {
        val scalaCode = "!@#"
        val result = Scala3CompilerUtils.runCompiler(scalaCode)

        result match {
            case Failure(errors) if errors.contains("Illegal start of toplevel definition") => ()
            case _ => fail("Error must be reported when valid invalid is compiled")
        }
    }
}