package scala_proto_deps;

import some.TestMessage;

public class UseTestMessage {

  private final TestMessage m = new TestMessage("", null);

  public TestMessage getM() {
    return m;
  }
}
