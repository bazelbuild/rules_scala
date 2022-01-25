package scalarules.test.extra_protobuf_generator

import com.google.protobuf.ExtensionRegistry
import com.google.protobuf.compiler.PluginProtos.{CodeGeneratorRequest, CodeGeneratorResponse}
import com.google.protobuf.Descriptors._
import scalapb.compiler.{ProtobufGenerator, DescriptorImplicits, ProtoValidation, GeneratorException, GeneratorParams, FunctionalPrinter}
import scalapb.options.compiler.Scalapb
import protocbridge.{ProtocCodeGenerator, Artifact}
import scala.collection.JavaConverters._

class CustomProtobufGenerator(
    params: GeneratorParams,
    implicits: DescriptorImplicits
) extends ProtobufGenerator(params, implicits) {
  import implicits._
  import ProtobufGenerator._

  def printCustomMessage(printer: FunctionalPrinter, message: Descriptor): FunctionalPrinter = {
    printer
      .add(s"final case object Custom${message.getName}{}")
  }

  override def generateSingleScalaFileForFileDescriptor(
      file: FileDescriptor
  ): Seq[CodeGeneratorResponse.File] = {
    val code =
      scalaFileHeader(
        file,
        false
      ).print(file.getMessageTypes.asScala)(printCustomMessage)
        .result()

    val b = CodeGeneratorResponse.File.newBuilder()
    b.setName(file.scalaDirectory + "/Custom" + file.getName + ".scala")
    b.setContent(code)
    List(b.build)
  }

}


object ExtraProtobufGenerator extends ProtocCodeGenerator {
   override def run(req: Array[Byte]): Array[Byte] = {
    val registry = ExtensionRegistry.newInstance()
    Scalapb.registerAllExtensions(registry)
    val request = CodeGeneratorRequest.parseFrom(req)
    handleCodeGeneratorRequest(request).toByteArray
  }

    def handleCodeGeneratorRequest(request: CodeGeneratorRequest): CodeGeneratorResponse = {
    val b = CodeGeneratorResponse.newBuilder
    ProtobufGenerator.parseParameters(request.getParameter) match {
      case Right(params) =>
        try {
          val filesByName: Map[String, FileDescriptor] =
            request.getProtoFileList.asScala.foldLeft[Map[String, FileDescriptor]](Map.empty) {
              case (acc, fp) =>
                val deps = fp.getDependencyList.asScala.map(acc)
                acc + (fp.getName -> FileDescriptor.buildFrom(fp, deps.toArray))
            }

          val implicits = new DescriptorImplicits(params, filesByName.values.toVector)
          val generator = new CustomProtobufGenerator(params, implicits)
          val validator = new ProtoValidation(implicits)
          validator.validateFiles(filesByName.values.toSeq)
          import implicits.ExtendedFileDescriptor
          request.getFileToGenerateList.asScala.foreach { name =>
            val file = filesByName(name)
            val responseFiles =
                generator.generateSingleScalaFileForFileDescriptor(file)
            b.addAllFile(responseFiles.asJava)
          }
        } catch {
          case e: GeneratorException =>
            b.setError(e.message)
        }
      case Left(error) =>
        b.setError(error)
    }
    b.build
  }

}
