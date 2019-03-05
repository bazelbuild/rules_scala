import org.scalatest.FlatSpec
import scala.util.Try

class OverrideProtoTest extends FlatSpec {

  "Looking for test4 proto at the right path" should "succeed" in {
    prototest.TestProto4
  }
}
