package example
import org.scalatest.funsuite.AnyFunSuite

class TestScala extends AnyFunSuite {

  test("test") {

    System.loadLibrary("hello-jni")

    val hello = new Hello()
    assert(hello.hello("Scala") == "Hello, Scala")

  }

}
