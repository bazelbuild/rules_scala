package third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer

import scala.reflect.io.AbstractFile
import scala.tools.nsc.plugins.{Plugin, PluginComponent}
import scala.tools.nsc.{Global, Phase}

import third_party.utils.src.main.io.bazel.rulesscala.utils.Utils

class DependencyAnalyzer(val global: Global) extends Plugin {
  val name = "dependency-analyzer"
  val description =
    "Analyzes the used dependencies and fails the compilation " +
      "if they are not explicitly used as direct dependencies (only declared transitively)"
  val components = List[PluginComponent](Component)

  var indirect: Map[String, String] = Map.empty
  var direct: Set[String] = Set.empty
  var analyzerMode: String = "error"
  var currentTarget: String = "NA"

  def decodeTarget(target: String): String = target.replace(";", ":")

  override def init(options: List[String], error: (String) => Unit): Boolean = {
    var indirectJars: Seq[String] = Seq.empty
    var indirectTargets: Seq[String] = Seq.empty

    for (option <- options) {
      option.split(":").toList match {
        case "direct-jars" :: data => direct = data.map(decodeTarget).toSet
        case "indirect-jars" :: data => indirectJars = data;
        case "indirect-targets" :: data => indirectTargets = data.map(decodeTarget)
        case "current-target" :: target => currentTarget = target.map(decodeTarget).head
        case "mode" :: mode => analyzerMode = mode.head
        case unknown :: _ => error(s"unknown param $unknown")
        case Nil =>
      }
    }

    indirect = indirectJars.zip(indirectTargets).toMap

    true
  }


  private object Component extends PluginComponent {
    val global: DependencyAnalyzer.this.global.type =
      DependencyAnalyzer.this.global

    import global._

    override val runsAfter = List("jvm")

    val phaseName: String = DependencyAnalyzer.this.name

    private def warnOrError(messages: Set[String]): Unit = analyzerMode match {
      case "error" => messages.foreach(reporter.error(NoPosition, _))
      case "warn" => messages.foreach(reporter.warning(NoPosition, _))
    }

    override def newPhase(prev: Phase): StdPhase = new StdPhase(prev) {
      override def run(): Unit = {

        super.run()

        val usedJars = Utils.findUsedJars(global)

        warnOrError(indirectTargetsFound(usedJars))
      }

      private def indirectTargetsFound(usedJars: Set[AbstractFile]): Set[String] = {
        for {
          usedJar <- usedJars
          usedJarPath = usedJar.path
          target <- indirect.get(usedJarPath) if !direct.contains(usedJarPath)
        } yield
            s"""Target '$target' is used but isn't explicitly declared, please add it to the deps.
               |You can use the following buildozer command:
               |buildozer 'add deps $target' $currentTarget""".stripMargin
      }

      override def apply(unit: CompilationUnit): Unit = ()
    }

  }
}
