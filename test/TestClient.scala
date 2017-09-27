package test.proto

import java.util.concurrent.TimeUnit
import java.util.logging.{Level, Logger}

import test.{TestRequest, TestMessage}
import test2.TestResponse1
import test3.TestResponse2
import test_service.TestServiceGrpc
import test_service.TestServiceGrpc.TestServiceBlockingStub

import io.grpc.{StatusRuntimeException, ManagedChannelBuilder, ManagedChannel}

object TestClient {
  def apply(host: String, port: Int): TestClient = {
    val channel = ManagedChannelBuilder.forAddress(host, port).usePlaintext(true).build
    val blockingStub = TestServiceGrpc.blockingStub(channel)
    new TestClient(channel, blockingStub)
  }

  def main(args: Array[String]): Unit = {
    val client = TestClient("localhost", 50051)
    try {
      val msg = args.headOption.getOrElse("ping")
      client.send(msg)
    } finally {
      client.shutdown()
    }
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

  /** Say hello to server. */
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
