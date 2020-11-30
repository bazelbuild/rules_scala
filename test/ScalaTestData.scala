import org.scalatest.flatspec.AnyFlatSpec

import scala.io.Source

class RunfileSpec extends AnyFlatSpec {

  "The text property" should "point to a runfile" in {
    Option(System.getProperty("text"))
      .map { path =>
        val bufferedSource = Source.fromFile(path)
        for (line <- bufferedSource.getLines) {
          println(line.toUpperCase)
        }
        bufferedSource.close
      }
      .getOrElse(throw new IllegalStateException("text property missing"))
  }
}
