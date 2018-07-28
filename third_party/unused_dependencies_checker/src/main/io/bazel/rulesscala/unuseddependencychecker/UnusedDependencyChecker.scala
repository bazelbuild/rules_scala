package third_party.unused_dependency_checker.src.main.io.bazel.rulesscala.unused_dependency_checker

import scala.reflect.io.AbstractFile
import scala.tools.nsc.plugins.{Plugin, PluginComponent}
import scala.tools.nsc.{Global, Phase}
import third_party.utils.src.main.io.bazel.rulesscala.utils.Utils._

class UnusedDependencyChecker(val global: Global) extends Plugin { self =>
  val name = "unused-dependency-checker"
  val description = "Errors if there exists dependencies that are not used"

  val components: List[PluginComponent] = List[PluginComponent](Component)

  var direct: Map[String, String] = Map.empty
  var analyzerMode: AnalyzerMode = Error
  var currentTarget: String = "NA"

  override def init(options: List[String], error: (String) => Unit): Boolean = {
    var directJars: Seq[String] = Seq.empty
    var directTargets: Seq[String] = Seq.empty

    for (option <- options) {
      option.split(":").toList match {
        case "direct-jars" :: data => directJars = data.map(decodeTarget)
        case "direct-targets" :: data => directTargets = data.map(decodeTarget)
        case "current-target" :: target :: _ => currentTarget = decodeTarget(target)
        case "mode" :: mode :: _ => parseAnalyzerMode(mode).foreach(analyzerMode = _)
        case unknown :: _ => error(s"unknown param $unknown")
        case Nil =>
      }
    }

    direct = directJars.zip(directTargets).toMap

    true
  }


  private object Component extends PluginComponent {
    val global: Global = self.global

    import global._

    override val runsAfter = List("jvm")

    val phaseName: String = self.name

    private def warnOrError(messages: Set[String]): Unit = {
      val reportFunction: String => Unit = analyzerMode match {
        case Error => reporter.error(NoPosition, _)
        case Warn => reporter.warning(NoPosition, _)
      }

      messages.foreach(reportFunction)
    }

    override def newPhase(prev: Phase): StdPhase = new StdPhase(prev) {
      override def run(): Unit = {
        super.run()

        warnOrError(unusedDependenciesFound)
      }

      private def unusedDependenciesFound: Set[String] = {
        val usedJars: Set[AbstractFile] = findUsedJars(global)
        val directJarPaths = direct.keys.toSet
        val usedJarPaths = usedJars.map(_.path)

        directJarPaths.diff(usedJarPaths)
          .map(direct.get)
          .collect {
            case Some(target) =>
              s"""Target '$target' is specified as a dependency to $currentTarget but isn't used, please remove it from the deps.
                 |You can use the following buildozer command:
                 |buildozer 'remove deps $target' $currentTarget
                 |""".stripMargin
          }
      }

      override def apply(unit: CompilationUnit): Unit = ()
    }
  }
}

