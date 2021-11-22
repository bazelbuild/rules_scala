import org.scalatest.flatspec.AnyFlatSpec

class GetResourceTest extends AnyFlatSpec {
  it should "have file available to grab" in {
    assert(getClass.getResource("/a/b/xxx.txt") != null)
  }

  it should "have directory available to grab" in {
    assert(getClass.getResource("/a/b") != null)
  }
}
