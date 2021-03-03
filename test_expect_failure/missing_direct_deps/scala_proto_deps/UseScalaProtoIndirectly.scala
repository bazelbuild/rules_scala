package scala_proto_deps

import some.TestMessage

class UseScalaProtoIndirectly {
  val foo: TestMessage = new UseTestMessage().getM
}