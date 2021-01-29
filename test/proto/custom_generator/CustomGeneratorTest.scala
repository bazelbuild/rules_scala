package test.proto.custom_generator

import org.scalatest.flatspec.AnyFlatSpec

import scala.util.Try

class CustomGeneratorTest extends AnyFlatSpec {

  "custom generator" should "be invoked" in {
    assert(
      Try(Class.forName("custom_generator.dummy")).isSuccess
    )
  }

}
