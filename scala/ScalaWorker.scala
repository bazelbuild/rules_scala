package com.databricks.bazel

import java.nio.charset.StandardCharsets.UTF_8

import com.google.devtools.build.lib.worker.WorkerProtocol.Input
import com.google.devtools.build.lib.worker.WorkerProtocol.WorkRequest
import com.google.devtools.build.lib.worker.WorkerProtocol.WorkResponse

import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException
import java.io.PrintStream
import java.nio.file.Files
import java.nio.file.Paths
import java.net.ServerSocket
import java.util.ArrayList
import java.util.LinkedHashMap
import java.util.{List => JList}
import java.util.Map.Entry
import java.util.UUID

import scala.collection.JavaConverters._
import scala.sys.process._

import com.typesafe.zinc.{Main => ZincMain, Nailgun, ZincClient}


/**
 * An example implementation of a worker process that is used for integration tests.
 */
object ScalaWorker {

  // A UUID that uniquely identifies this running worker process.
  private val workerUuid = UUID.randomUUID()

  // A counter that increases with each work unit processed.
  private var workUnitCounter = 1

  // If true, returns corrupt responses instead of correct protobufs.
  private var poisoned = false

  // Keep state across multiple builds.
  private val inputs = new LinkedHashMap[String, String]()

  private var serverArgs = ""

  private def getFreePort(): Int = {
    val sock = new ServerSocket(0)
    val port = sock.getLocalPort
    sock.close()
    port
  }

  private var zincClient: ZincClient = _

  private var zincPort: Int = 0

  private var nailgunProcess: Process = _

  private def attachShutdownHook() {
    Runtime.getRuntime().addShutdownHook(new Thread() {
      override def run() {
        if (nailgunProcess != null) {
          nailgunProcess.destroy()
        }
      }
    })
  }

  private val serverOutput = new StringBuilder()

  private def startServer(classpath: String): Unit = {
    attachShutdownHook()
    zincPort = getFreePort()

    val logger = new ProcessLogger {
      def buffer[T](fn: => T): T = fn
      def err(s: => String): Unit = serverOutput.append(s).append("\n")
      def out(s: => String): Unit = serverOutput.append(s).append("\n")
    }

    // Options copied from Nailgun.scala in Zinc
    val options = List("-cp", classpath, "-server", "-Xms1024m", "-Xmx3g", "-XX:MaxPermSize=384m",
      "-XX:ReservedCodeCacheSize=192m")
    val cmd = "java" :: options ++ Seq(classOf[Nailgun].getName, s"$zincPort")
    val builder = Process(cmd)
    this.nailgunProcess = builder.run(logger)

    serverArgs = cmd.mkString(" ")
    zincClient = new ZincClient(port = zincPort)
  }

  private def awaitServer() {
    var count = 0
    while (!zincClient.serverAvailable && (count < 50)) {
      try { Thread.sleep(100) } catch { case _: InterruptedException => }
      count += 1
    }
  }

  def main(args: Array[String]): Unit = {
    if (args.contains("--persistent_worker")) {
      startServer(args(0))
      runPersistentWorker(args)
    } else {
      // This is a single invocation of the example that exits after it processed the request.
      ZincMain.run(args, cwd = None)
    }
  }

  private def listFiles(f: File): Seq[String] = {
    val current = f.listFiles
    val files = current.filter(_.isFile).map(_.getAbsolutePath)
    val directories = current.filter(_.isDirectory)
    files ++ directories.flatMap(listFiles)
  }

  // Extract a src jar to a temporary directory and return the list of extracted files
  private def expandSrcJar(path: String): Seq[String] = {
    val tempDir = Files.createTempDirectory(null).toFile
    Seq("unzip", "-q", path, "-d", tempDir.getAbsolutePath).!!
    listFiles(tempDir)
  }

  @throws[IOException]
  private def runPersistentWorker(args: Array[String]) {
    val originalStdOut = System.out
    val originalStdErr = System.err

    while (true) {
      try {
        val request = WorkRequest.parseDelimitedFrom(System.in)
        if (request == null) {
          return
        }

        inputs.clear()

        for (input <- request.getInputsList().asScala) {
          inputs.put(input.getPath(), input.getDigest().toStringUtf8())
        }

        val baos = new ByteArrayOutputStream()
        var exitCode = 0

        val ps = new PrintStream(baos)
        try {
          System.setOut(ps)
          System.setErr(ps)

          var clientArgs: Seq[String] = null

          try {
            clientArgs = request.getArgumentsList.asScala.flatMap { arg =>
              // srcjars must be extracted before we can pass them to zinc
              if (arg.endsWith(".srcjar")) {
                expandSrcJar(arg)
              } else {
                Seq(arg)
              }
            }
            awaitServer()
            exitCode = zincClient.run(
              args = clientArgs,
              cwd = new File(System.getProperty("user.dir")),
              out = ps,
              err = ps
            )
          } catch {
            case e: Exception =>
              // We use System.out.println as not to accidentally write to real stdout
              System.out.println("Startup Args:")
              args.foreach(arg => System.out.println("Arg: " + arg))
              System.out.println("Server args: " + serverArgs)
              System.out.println("Server output: " + serverOutput.toString)
              System.out.println("Unexpanded Client Args:")
              request.getArgumentsList.asScala.foreach(arg => System.out.println("Arg: " + arg))
              if (clientArgs != null) {
                System.out.println("Expanded Client Args:")
                clientArgs.foreach(arg => System.out.println("Arg: " + arg))
              } else {
                System.out.println("======== CLIENT ARG EXPANSION MAY HAVE FAILED =======")
              }

              e.printStackTrace()
              exitCode = 1
          }
        } finally {
          System.setOut(originalStdOut)
          System.setErr(originalStdErr)
        }

        if (poisoned) {
          System.out.println("I'm a poisoned worker and this is not a protobuf.")
        } else {
          WorkResponse.newBuilder()
            .setOutput(baos.toString())
            .setExitCode(exitCode)
            .build()
            .writeDelimitedTo(System.out)
        }
        System.out.flush()

        /*
        if (workerOptions.exitAfter > 0 && workUnitCounter > workerOptions.exitAfter) {
          return
        }

        if (workerOptions.poisonAfter > 0 && workUnitCounter > workerOptions.poisonAfter) {
          poisoned = true
        }
        */
      } finally {
        // Be a good worker process and consume less memory when idle.
        System.gc()
      }
    }
  }
}

