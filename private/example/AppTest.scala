import org.scalatest._

class AppTest extends FlatSpec with Matchers {
  it should "have a successful test" in {
    System.err.println(s"hello, world from ${scala.util.Properties.versionString}!")

    App.version should be (scala.util.Properties.versionString)
  }
}
