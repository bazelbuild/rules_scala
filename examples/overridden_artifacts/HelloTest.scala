package overriddenartifactstest

import org.scalatest.funsuite.AnyFunSuite

class HelloTest extends AnyFunSuite:
  test("greetings includes the correct Scala version number") {
    val hello = new Hello(util.Properties.versionNumberString)

    // Apparently Scala 3 code will still return a Scala 2 version number:
    // - https://users.scala-lang.org/t/what-scala-library-version-is-used-by-which-scala-3-version/9999
    assert(hello.greetings().endsWith("2.13.14."))
  }
