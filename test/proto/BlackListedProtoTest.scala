import org.scalatest.flatspec._

import scala.util.Try

class BlackListedProtoTest extends AnyFlatSpec {

  "looking for a blacklisted proto" should "fail" in {
    // The direct test dep should be here.
    test.proto.test_service.TestServiceGrpc

    assert(
      Try(Class.forName("test.proto.blacklisted_proto.BlackListedProtoMessage")).isFailure)
  }
}
