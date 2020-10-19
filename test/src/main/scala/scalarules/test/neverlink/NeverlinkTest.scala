package neverlink

import org.scalatest._

class NeverlinkTest extends FlatSpec {
  "neverlink=True" should "exclude jar from classpath" in {
    getClass.getClassLoader.loadClass("neverlink.A")
  }

  "neverlink=False" should "not include jar in classpath" in {
    assertThrows[ClassNotFoundException]{
      getClass.getClassLoader.loadClass("neverlink.B")
    }
  }
}