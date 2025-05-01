package scripts

import protocgen.{CodeGenApp,CodeGenRequest,CodeGenResponse}

object ScalaPbCodeGenerator extends CodeGenApp {
    def process(request: CodeGenRequest): CodeGenResponse =
        scalapb.ScalaPbCodeGenerator.process(request)
}
