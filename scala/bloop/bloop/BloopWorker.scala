package io.bazel.rules_scala.bloop

import java.io.{File, InputStream}
import java.nio.file.{FileSystems, Files, Path, Paths}
import java.time.Instant
import java.util
import java.util.concurrent.Executors

import bloop.bloopgun.core.Shell
import bloop.config.Config.Scala
import bloop.config.{Config => BloopConfig}
import bloop.launcher.bsp.BspBridge
import bloop.launcher.{Launcher => BloopLauncher}
import ch.epfl.scala.bsp4j._
import com.google.gson.Gson
import io.bazel.rulesscala.jar.JarCreator
import io.bazel.rulesscala.worker.Worker
import net.sourceforge.argparse4j.ArgumentParsers
import net.sourceforge.argparse4j.impl.Arguments
import net.sourceforge.argparse4j.inf.Namespace
import org.apache.commons.io.FileUtils
import org.eclipse.lsp4j.jsonrpc.{Launcher => LspLauncher}

import scala.collection.JavaConverters._
import scala.compat.java8.FutureConverters._
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration.Duration
import scala.concurrent.{Await, Promise}
import scala.util.Try

trait BloopServer extends BuildServer with ScalaBuildServer

object BloopUtil {

  class BloopExtraBuildParams() {
    val ownsBuildFiles: Boolean = true
  }

  //At the moment just print results
  val buildClient = new BuildClient {

    def afterBuildTaskFinish(bti: String) = {
      println("afterBuildTaskFinish", bti)
    }

    override def onBuildShowMessage(params: ShowMessageParams): Unit = println("onBuildShowMessage", params)

    override def onBuildLogMessage(params: LogMessageParams): Unit = println("onBuildLogMessage", params)

    override def onBuildTaskStart(params: TaskStartParams): Unit = println("onBuildTaskStart", params)

    override def onBuildTaskProgress(params: TaskProgressParams): Unit = println("onBuildTaskProgress", params)

    override def onBuildTaskFinish(params: TaskFinishParams): Unit = {
      println("onBuildTaskFinish", params)
    }

    override def onBuildPublishDiagnostics(params: PublishDiagnosticsParams): Unit = println("onBuildPublishDiagnostics", params)

    override def onBuildTargetDidChange(params: DidChangeBuildTarget): Unit = println("onBuildTargetDidChange", params)
  }

  def initBloop(): BloopServer = {
    val emptyInputStream = new InputStream() {
      override def read(): Int = -1
    }

    val dir = Files.createTempDirectory(s"bsp-launcher")
    val bspBridge = new BspBridge(
      emptyInputStream,
      System.err,
      Promise[Unit](),
      System.err,
      Shell.default,
      dir
    )

    BloopLauncher.connectToBloopBspServer("1.1.2", false, bspBridge, List()) match {
      case Right(Right(Some(socket))) => {
        val es = Executors.newCachedThreadPool()
        val launcher = new LspLauncher.Builder[BloopServer]()
          .setRemoteInterface(classOf[BloopServer])
          .setExecutorService(es)
          .setInput(socket.getInputStream)
          .setOutput(socket.getOutputStream)
          .setLocalService(buildClient)
          .create()

        launcher.startListening()
        val bloopServer = launcher.getRemoteProxy

        buildClient.onConnectWithServer(bloopServer)

        System.err.println("attempting build initialize")

        val initBuildParams = {
          val p = new InitializeBuildParams(
            "bazel",
            "1.3.4",
            "2.0.0-M4",
            s"file:///Users/syed.jafri/dev/local_rules_scala", //TODO don't hardcode
            new BuildClientCapabilities(List("scala").asJava)
          )
          val gson = new Gson()
          p.setData(gson.toJsonTree(new BloopExtraBuildParams()))
          p
        }

        Await.result(bloopServer.buildInitialize(initBuildParams).toScala.map(initializeResults => {
          System.err.println(s"initialized: Results $initializeResults")
          bloopServer.onBuildInitialized()
        }), Duration.Inf)

        bloopServer
      }
    }
  }
}

object BloopWorker extends Worker.Interface {
  val bloopServer = BloopUtil.initBloop()
  def main(args: Array[String]): Unit = Worker.workerMain(args, BloopWorker)

  private val pwd = {
    val uncleanPath = FileSystems.getDefault().getPath(".").toAbsolutePath.toString
    uncleanPath.substring(0, uncleanPath.size - 2)
  }

  /**
   * namespace.getList[File] gives me an error so I wrote this
   * @param str
   */
  private def parseFileList(namespace: Namespace, key: String): List[Path] = {
    Option(namespace.getString(key)).fold(
      List[Path]()
    )(
      _.split(", ").toList.map(
        relPath => Paths.get(s"$pwd/$relPath").toAbsolutePath //.toRealPath()
      )
    )
  }

  /**
   * Parse the jars needed for the scala compiler from the classpath.
   * The jars needed are specified in BUILD
   */
  private def getScalaJarsFromCP(): (List[Path], String) = {
    val scalaCPs = Set("io_bazel_rules_scala_scala_compiler", "io_bazel_rules_scala_scala_library", "io_bazel_rules_scala_scala_reflect", "io_bazel_rules_scala_scala_xml")
    val classPaths = System.getProperty("java.class.path").split(":").toList
    val paths = classPaths.filter(cp => scalaCPs.exists(cp.contains)).map(s => Paths.get(s"$pwd/$s").toRealPath())

    val re = raw".*scala-.*-(2.*).jar".r
    val version = paths.head.toString match {
      case re(s) => s
    }

    (paths, version)
  }

  def work(args: Array[String]) {

    val startTime = Instant.now.toEpochMilli
    var argsArrayBuffer = scala.collection.mutable.ArrayBuffer[String]()
    for (i <- 0 to args.size - 1) {
      argsArrayBuffer += args(i)
    }

    val parser = ArgumentParsers.newFor("bloop").addHelp(true).defaultFormatWidth(80).fromFilePrefix("@").build
    parser.addArgument("--label").required(true)
    parser.addArgument("--sources").`type`(Arguments.fileType)
    parser.addArgument("--target_classpath").`type`(Arguments.fileType)
    parser.addArgument("--build_file_path").`type`(Arguments.fileType)
    parser.addArgument("--bloopDir").`type`(Arguments.fileType)
    parser.addArgument("--manifest").`type`(Arguments.fileType)
    parser.addArgument("--jarOut").`type`(Arguments.fileType)
    parser.addArgument("--statsfile").`type`(Arguments.fileType)
    parser.addArgument("--bloopDependencies")

    val namespace = parser.parseArgsOrFail(argsArrayBuffer.toArray)
    val label = namespace.getString("label")
    val srcs = parseFileList(namespace, "sources")
    val classpath = parseFileList(namespace, "target_classpath")
    val workspaceDir = namespace.get[File]("bloopDir").toPath
    val manifestPath = namespace.getString("manifest")
    val jarOut = namespace.getString("jarOut")
    val statsfile = namespace.get[File]("statsfile").toPath
    val bloopDependencies = Option(namespace.get[String]("bloopDependencies"))
      .map(_.split(", ").toList).getOrElse(List())

    System.err.println(s"WORKER Compiling $label")

    val bloopDir = workspaceDir.resolve(".bloop").toAbsolutePath
    val bloopOutDir = bloopDir.resolve("out").toAbsolutePath
    val projectOutDir = bloopOutDir.resolve(label).toAbsolutePath
    val projectClassesDir = projectOutDir.resolve("classes").toAbsolutePath
    val bloopConfigPath = bloopDir.resolve(s"$label.json")

    System.err.println(s"BloopDir: $bloopDir")

    def generateBloopConfig() = {
      Files.createDirectories(projectClassesDir)
      val (scalaJars, scalaVersion) = getScalaJarsFromCP()

      val bloopConfig = BloopConfig.File(
        version = BloopConfig.File.LatestVersion,
        project = BloopConfig.Project(
          name = label,
          directory = workspaceDir,
          sources = srcs.map(_.toRealPath()),
          dependencies = bloopDependencies,
          classpath = classpath,
          out = projectOutDir,
          classesDir = projectClassesDir,
          resources = None,
          `scala` = Some(Scala(
            "org.scala-lang",
            "scala-compiler",
            scalaVersion,
            List(),
            scalaJars,
            None,
            None
          )),
          java = None,
          sbt = None,
          test = None,
          platform = None,
          resolution = None
        )
      )

      Files.write(bloopConfigPath, bloop.config.toStr(bloopConfig).getBytes)
    }

    def compile() = {
      val buildTargetId = List(new BuildTargetIdentifier(s"file://$workspaceDir/?id=$label"))
      System.err.println(s"Attempt compile for $buildTargetId")
      val compileParams = new CompileParams(buildTargetId.asJava)

      val compile = bloopServer.buildTargetCompile(compileParams).toScala.map(cr => {
        System.err.println(cr)
        if (cr.getStatusCode() != StatusCode.OK) {
          throw new RuntimeException("Status code was not OK") //TODO
        }
        ()
      })

      Await.result(compile, Duration.Inf)
      val tempJarFiles = Files.createTempDirectory(s"$label-jar")
      FileUtils.copyDirectory(projectClassesDir.toFile, tempJarFiles.toFile, true)
      JarCreator.buildJar(Array("-m", manifestPath, jarOut, tempJarFiles.toString))

      //TODO I get an exception that I'm having a hard time figuring out without this.
      Thread.sleep(500)

      Files.write(statsfile, s"build_time=${Instant.now.toEpochMilli - startTime}".getBytes)
    }

    generateBloopConfig()
    compile()
  }
}