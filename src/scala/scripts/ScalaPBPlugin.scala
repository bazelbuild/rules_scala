package scripts

import com.google.protobuf.compiler.PluginProtos.CodeGeneratorRequest.parseFrom
import scalapb.compiler.ProtobufGenerator.handleCodeGeneratorRequest

object ScalaPBPlugin extends App {

  handleCodeGeneratorRequest(parseFrom(System.in)).writeTo(System.out)

}
