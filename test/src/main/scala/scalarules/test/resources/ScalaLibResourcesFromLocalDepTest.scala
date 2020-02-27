package scalarules.test 

class ResourceTest extends org.scalatest.FlatSpec {
  "resource_test" should "pack python resource next to generated code" in {
    assert(getClass.getResource("/py_resource_binary") != null)
  }
}