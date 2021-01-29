package test.proto.custom_generator

import com.google.protobuf.compiler.PluginProtos.{CodeGeneratorRequest, CodeGeneratorResponse}
import protocbridge.ProtocCodeGenerator

import scala.collection.JavaConverters._

object CustomGenerator extends ProtocCodeGenerator {
  override def run(input: Array[Byte]): Array[Byte] = {
    val request = CodeGeneratorRequest.parseFrom(input)
    val response = CodeGeneratorResponse.newBuilder

    for (file <- request.getFileToGenerateList.asScala) {
      val name = file.replace('/', '_').replace('.', '_')
      response.addFileBuilder()
        .setName(s"$name.scala")
        .setContent(s"object $name")
        .build()
    }

    response.build().toByteArray
  }
}



