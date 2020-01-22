class PackProtosTest extends org.scalatest.FlatSpec {
  "scala_proto_library" should "pack input proto next to generated code" in {
    assert(getClass.getResource("test/proto/standalone.proto") != null)
    assert(getClass.getResource("proto/standalone.proto") != null)
    assert(getClass.getResource("standalone.proto") != null)
    assert(getClass.getResource("prefix/test/proto/standalone.proto") != null)
    assert(getClass.getResource("prefix/proto/standalone.proto") != null)
    assert(getClass.getResource("test/proto/some/path/nested.proto") != null)
    assert(getClass.getResource("path/nested.proto") != null)
    assert(getClass.getResource("prefix/test/proto/some/path/nested.proto") != null)
    assert(getClass.getResource("prefix/path/nested.proto") != null)
  }
}
