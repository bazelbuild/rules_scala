package test.proto.custom_generator

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers._

class DummyGeneratorTest extends AnyFlatSpec with should.Matchers {

  "dummy generator" should "generate a dummy object" in {
    noException should be thrownBy Class.forName("custom_generator.dummy")
  }

}
