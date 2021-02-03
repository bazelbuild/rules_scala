package test.proto.custom_generator

object FailingGenerator extends protocbridge.ProtocCodeGenerator {
  override def run(request: Array[Byte]): Array[Byte] =
    throw new RuntimeException("expected generator failure")
}
