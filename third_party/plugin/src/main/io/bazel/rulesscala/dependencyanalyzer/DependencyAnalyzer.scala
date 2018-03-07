package third_party.plugin.src.main.io.bazel.rulesscala.dependencyanalyzer

import scala.reflect.io.AbstractFile
import scala.tools.nsc.plugins.{Plugin, PluginComponent}
import scala.tools.nsc.{Global, Phase}
import scala.Console._
import java.io.File
import java.net.URI
import scala.tools.nsc.Settings
import scala.tools.nsc.classpath.FlatClassPathFactory

class DependencyAnalyzer(val global: Global) extends Plugin {

  val name = "dependency-analyzer"
  val description =
    "Analyzes the used dependencies and fails the compilation " +
      "if they are not explicitly used as direct dependencies (only declared transitively)"
  val components = List[PluginComponent](Component)

  var indirect: Map[String, String] = Map.empty
  var direct: Map[String, String] = Map.empty
  var analyzerMode: String = "error"
  var directJars: Seq[String] = Seq.empty
  var currentTarget: String = "NA"

  override def processOptions(options: List[String], error: (String) => Unit): Unit = {
    var indirectJars: Seq[String] = Seq.empty
    var indirectTargets: Seq[String] = Seq.empty
    var directTargets: Seq[String] = Seq.empty

    for (option <- options) {
      option.split(":").toList match {
        case "direct-jars" :: data => directJars = data
        case "direct-targets" :: data => directTargets = data.map(_.replace(";", ":"))
        case "indirect-jars" :: data => indirectJars = data
        case "indirect-targets" :: data => indirectTargets = data.map(_.replace(";", ":"))
        case "current-target" :: target => currentTarget = target.map(_.replace(";", ":")).head
        case "mode" :: mode => analyzerMode = mode.head
        case unknown :: _ => error(s"unknown param $unknown")
        case Nil =>
      }
    }
    indirect = indirectJars.zip(indirectTargets).toMap
    direct = directJars.zip(directTargets).toMap
  }

  private object Component extends PluginComponent {
    val global: DependencyAnalyzer.this.global.type =
      DependencyAnalyzer.this.global

    import global._

    override val runsAfter = List("jvm")

    val phaseName = DependencyAnalyzer.this.name

    override def newPhase(prev: Phase): StdPhase = new StdPhase(prev) {
      override def run(): Unit = {

        super.run()

        val usedJars = findUsedJars

        warnOnIndirectTargetsFoundIn(usedJars)
        warnOnUnusedTargetsFoundIn(usedJars)
      }

      private def warnOnUnusedTargetsFoundIn(usedJars: Set[AbstractFile]) = {
        val usedJarPaths = usedJars.map(_.path)
        for {
          directJar <- direct.keys if !usedJarPaths.contains(directJar)
          target <- direct.get(directJar)
        } {
          // TODO: Can we get the correct jar label here?
          val errorMessage =
            s"""${currentTarget} depends on '${target}' which depends on '${directJar}'.
               |${RESET}${GREEN}${directJar} is not used by ${currentTarget}. Please remove it from the deps.${RESET}""".stripMargin

          analyzerMode match {
            case "error" => reporter.error(NoPosition, errorMessage)
            case "warn" => reporter.warning(NoPosition, errorMessage)
          }
        }
      }

      private def warnOnIndirectTargetsFoundIn(usedJars: Set[AbstractFile]) = {
        for (usedJar <- usedJars;
             usedJarPath = usedJar.path;
             target <- indirect.get(usedJarPath) if !direct.contains(usedJarPath)) {
          val errorMessage =
            s"""Target '${target}' is used but isn't explicitly declared, please add it to the deps.
               |You can use the following buildozer command:
               |${RESET}${GREEN}buildozer 'add deps ${target}' ${currentTarget}${RESET}""".stripMargin

          analyzerMode match {
            case "error" => reporter.error(NoPosition, errorMessage)
            case "warn" => reporter.warning(NoPosition, errorMessage)
          }
        }
      }

      override def apply(unit: CompilationUnit): Unit = ()
    }

  }

  import global._

  private def findUsedJars: Set[AbstractFile] = {
    val jars = collection.mutable.Set[AbstractFile]()

    def walkTopLevels(root: Symbol): Unit = {
      def safeInfo(sym: Symbol): Type =
        if (sym.hasRawInfo && sym.rawInfo.isComplete) sym.info else NoType

      def packageClassOrSelf(sym: Symbol): Symbol =
        if (sym.hasPackageFlag && !sym.isModuleClass) sym.moduleClass else sym

      for (x <- safeInfo(packageClassOrSelf(root)).decls) {
        if (x == root) ()
        else if (x.hasPackageFlag) walkTopLevels(x)
        else if (x.owner != root) { // exclude package class members
          if (x.hasRawInfo && x.rawInfo.isComplete) {
            val assocFile = x.associatedFile
            if (assocFile.path.endsWith(".class") && assocFile.underlyingSource.isDefined)
              assocFile.underlyingSource.foreach(jars += _)
          }
        }
      }
    }

    exitingTyper {
      walkTopLevels(RootClass)
    }
    jars.toSet
  }
}
