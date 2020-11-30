import org.scalatest.flatspec._

import scala.util.Try

class CustomGeneratedObjectTest extends AnyFlatSpec {

  "Looking for the custom generated class" should "succeed" in {
    test_external_dep.CustomTestMessage
    assert(
      Try(Class.forName("test_external_dep.CustomTestMessage$")).isSuccess)
  }
}
