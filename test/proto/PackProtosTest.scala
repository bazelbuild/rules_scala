
class PackProtosTest extends org.scalatest.FlatSpec {

  "scala_proto_library" should "pack input proto next to generated code" in {
    assert(getClass.getResource("test/proto/test2.proto") != null)
  }
}
