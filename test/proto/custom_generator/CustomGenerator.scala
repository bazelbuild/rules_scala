package test.proto.custom_generator

import com.google.protobuf.compiler.PluginProtos.{CodeGeneratorRequest, CodeGeneratorResponse}
import protocbridge.ProtocCodeGenerator
import scalapb.compiler.ProtobufGenerator

import scala.collection.JavaConverters._

object CustomGenerator extends ProtocCodeGenerator {
  override def run(input: Array[Byte]): Array[Byte] = {
    val request = CodeGeneratorRequest.parseFrom(input)
    val response = CodeGeneratorResponse.newBuilder

    val filesByName = ProtobufGenerator.getFileDescByName(request)
    request.getFileToGenerateList.asScala.map(filesByName).foreach { f =>
      f.getMessageTypes.asScala.map(_.getName).foreach { m =>
        response.addFileBuilder()
          .setContent(s"class ${m}Custom {}")
          .setName("${m}Custom.scala")
          .build()
      }
    }

    response.build().toByteArray
  }
}



