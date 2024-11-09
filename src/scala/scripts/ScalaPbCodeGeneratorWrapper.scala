package scripts

import protocgen.{CodeGenApp,CodeGenRequest,CodeGenResponse}

object ScalaPbCodeGenerator extends CodeGenApp {
    def process(request: CodeGenRequest): CodeGenResponse = {
        try {
            scalapb.ScalaPbCodeGenerator.process(request)

        } catch {
          case e: Throwable =>
            val stackStream = new java.io.ByteArrayOutputStream
            e.printStackTrace(new java.io.PrintStream(stackStream))
            CodeGenResponse.fail(stackStream.toString())
        }
    }
}
