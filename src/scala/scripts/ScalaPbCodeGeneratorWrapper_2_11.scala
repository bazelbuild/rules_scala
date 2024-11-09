package scripts
import com.google.protobuf.compiler.PluginProtos.CodeGeneratorResponse

object ScalaPbCodeGenerator extends protocbridge.ProtocCodeGenerator {
    override def run(req: Array[Byte]): Array[Byte] = {
        try {
            scalapb.ScalaPbCodeGenerator.run(req)

        } catch {
          case e: Throwable =>
            val b = CodeGeneratorResponse.newBuilder
            val stackStream = new java.io.ByteArrayOutputStream

            e.printStackTrace(new java.io.PrintStream(stackStream))
            b.setError(stackStream.toString())
            b.build.toByteArray
        }
    }
}
