package test.proto

import test.{TestRequest, TestMessage}
import test2.TestResponse1
import test3.TestResponse2
import test_service.TestServiceGrpc
import test_service.TestServiceGrpc.TestServiceBlockingStub

import io.grpc.{Server, ServerBuilder, StatusRuntimeException, ManagedChannelBuilder, ManagedChannel}

import java.util.concurrent.TimeUnit
import java.util.logging.{Level, Logger}

import scala.concurrent.{ExecutionContext, Future}

/**
 * Adapted from https://github.com/xuwei-k/grpc-scala-sample/blob/master/grpc-scala/src/main/scala/io/grpc/examples/helloworld/HelloWorldServer.scala
 */
object TestServer {
  private val logger = Logger.getLogger(classOf[TestServer].getName)

  def main(args: Array[String]): Unit = {
    val server = new TestServer(ExecutionContext.global)
    server.start()
    val client = TestClient("localhost", 50051)
    val msg = args.headOption.getOrElse("ping")
    client.send(msg)
    client.shutdown()
    server.stop()
  }

  private val port = 50051
}

class TestServer(executionContext: ExecutionContext) { self =>
  lazy val server: Server = ServerBuilder
    .forPort(TestServer.port)
    .addService(TestServiceGrpc.bindService(new TestServiceImpl, executionContext))
    .build

  private def start(): Unit = {
    server.start()
    TestServer.logger.info(s"Server started, listening on ${TestServer.port}")
    sys.addShutdownHook {
      System.err.println("*** shutting down gRPC server since JVM is shutting down")
      self.stop()
      System.err.println("*** server shut down")
    }
  }

  private def stop(): Unit = server.shutdown()

  private def blockUntilShutdown(): Unit = server.awaitTermination()

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

object TestClient {
  def apply(host: String, port: Int): TestClient = {
    val channel = ManagedChannelBuilder.forAddress(host, port).usePlaintext().build
    val blockingStub = TestServiceGrpc.blockingStub(channel)
    new TestClient(channel, blockingStub)
  }
}

class TestClient private(
  private val channel: ManagedChannel,
  private val blockingStub: TestServiceBlockingStub
) {
  private[this] val logger = Logger.getLogger(classOf[TestClient].getName)

  def shutdown(): Unit = {
    channel.shutdown.awaitTermination(5, TimeUnit.SECONDS)
  }

  def send(name: String): Unit = {
    logger.info("Will try to send " + name + " ...")
    val request = TestRequest()
    try {
      val response = blockingStub.testMethod1(request)
      logger.info("Response: " + response.testMsg)
    }
    catch {
      case e: StatusRuntimeException =>
        logger.log(Level.WARNING, "RPC failed: {0}", e.getStatus)
    }
  }
}
