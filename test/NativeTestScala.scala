package scala.test

import org.scalatest._

class NativeTestScala extends FlatSpec {
  "NativeLib" should "load C libraries" in {
    System.out.println("java.library.path: " + System.getProperty("java.library.path"));
    try {
      System.loadLibrary("NativeLibCompiledElsewhere")
    } catch {
      case _: UnsatisfiedLinkError => fail("Can't load NativeLibCompiledElsewhere")
    }
  }
}
