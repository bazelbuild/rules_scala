import org.scalatest.flatspec.AnyFlatSpec

class Zero extends AnyFlatSpec {
  "Equality" should "be tested" in {
    assert (0 == -0)
  }
}
