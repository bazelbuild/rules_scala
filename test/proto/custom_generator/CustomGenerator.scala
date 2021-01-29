package test.proto.custom_generator

import com.google.protobuf.compiler.PluginProtos.CodeGeneratorResponse
import protocbridge.ProtocCodeGenerator

object CustomGenerator extends ProtocCodeGenerator {
  override def run(request: Array[Byte]): Array[Byte] = {
    val response = CodeGeneratorResponse.newBuilder

    response.addFileBuilder()
      .setName("custom_generator/dummy.scala")
      .setContent("package custom_generator {object dummy}")
      .build()

    response.build().toByteArray
  }
}
