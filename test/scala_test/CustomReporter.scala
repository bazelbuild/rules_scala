package test.scala_test

import java.io.{File, PrintWriter}
import java.nio.file.Paths

import org.scalatest._
import org.scalatest.events.Event

class CustomReporter extends Reporter {
  override def apply(event: Event): Unit = {
    val flagDir = sys.env("TEST_UNDECLARED_OUTPUTS_DIR")
    val file = new File(Paths.get(flagDir,  "custom_reporter_check").toUri)
    val writer = new PrintWriter(file)
    writer.write("It's from custom reporter")
    writer.close()
  }
}