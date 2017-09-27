package test.proto

import test.{TestRequest, TestMessage}
import test2.TestResponse1
import test3.TestResponse2
import test_service.TestServiceGrpc

import io.grpc.{Server, ServerBuilder}

import java.util.logging.Logger

import scala.concurrent.{ExecutionContext, Future}

/**
 * Adapted from https://github.com/xuwei-k/grpc-scala-sample/blob/master/grpc-scala/src/main/scala/io/grpc/examples/helloworld/HelloWorldServer.scala
 */
object TestServer {
  private val logger = Logger.getLogger(classOf[TestServer].getName)

  def main(args: Array[String]): Unit = {
    val server = new TestServer(ExecutionContext.global)
    server.start()
    server.blockUntilShutdown()
  }

  private val port = 50051
}

class TestServer(executionContext: ExecutionContext) { self =>
  private[this] var server: Server = null

  private def start(): Unit = {
    server = ServerBuilder.forPort(TestServer.port).addService(TestServiceGrpc.bindService(new TestServiceImpl, executionContext)).build.start
    TestServer.logger.info("Server started, listening on " + TestServer.port)
    sys.addShutdownHook {
      System.err.println("*** shutting down gRPC server since JVM is shutting down")
      self.stop()
      System.err.println("*** server shut down")
    }
  }

  private def stop(): Unit = {
    if (server != null) {
      server.shutdown()
    }
  }

  private def blockUntilShutdown(): Unit = {
    if (server != null) {
      server.awaitTermination()
    }
  }

  private class TestServiceImpl extends TestServiceGrpc.TestService {
    override def testMethod1(request: TestRequest): Future[TestResponse1] = {
      val response = TestResponse1().withTestMsg(TestMessage(Some("foo")))
      Future.successful(response)
    }

    override def testMethod2(request: TestRequest): Future[TestResponse2] = {
      val response = TestResponse2().withTestMsg(TestMessage(Some("bar")))
      Future.successful(response)
    }
  }

}
