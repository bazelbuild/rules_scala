import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

class AppTest extends AnyFlatSpec with Matchers {
  it should "have a successful test" in {
    System.err.println(s"hello, world from ${scala.util.Properties.versionString}!")

    App.version should be (scala.util.Properties.versionString)
  }
}
