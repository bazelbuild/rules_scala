package scalarules.test.extra_protobuf_generator

import com.google.protobuf.Descriptors.{Descriptor, FileDescriptor}
import scalapb.compiler.DescriptorImplicits

class ProtobufAdapter(implicits: DescriptorImplicits) {
    import implicits._

    def nameSymbol(message: Descriptor): String = message.scalaType.nameSymbol

    def fileDescriptorObjectName(file: FileDescriptor): String =
        file.fileDescriptorObject.name
}
