package third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer

import scala.collection.mutable
import scala.reflect.io.AbstractFile
import scala.tools.nsc.plugins.{Plugin, PluginComponent}
import scala.tools.nsc.{Global, Phase}

object AnalyzerMode {
  case object Error extends AnalyzerMode
  case object Warn extends AnalyzerMode
  case object Off extends AnalyzerMode

  def parse(mode: String): Option[AnalyzerMode] = {
    mode match {
      case "error" => Some(Error)
      case "warn" => Some(Warn)
      case "off" => Some(Off)
      case _ => None
    }
  }
}

sealed trait AnalyzerMode

object DependencyTrackingMethod {
  case object HighLevel extends DependencyTrackingMethod

  def parse(mode: String): Option[DependencyTrackingMethod] = {
    mode match {
      case "high-level" => Some(HighLevel)
      case _ => None
    }
  }
}

sealed trait DependencyTrackingMethod

class TargetSet(
  prefix: String,
  jarsSeq: Seq[String],
  targetsSeq: Seq[String]
) {
  private lazy val jarToTargetMap: Map[String, String] = {
    require(targetsSeq.size == jarsSeq.size, s"Arguments $prefix-jars and $prefix-targets had mismatched size")

    jarsSeq.zip(targetsSeq).toMap
  }

  def targetFromJarOpt(jar: String): Option[String] = {
    jarToTargetMap.get(jar)
  }

  lazy val jarSet: Set[String] = {
    jarsSeq.toSet
  }
}

case class DependencyAnalyzerSettings(
  indirectTargetSet: TargetSet,
  directTargetSet: TargetSet,
  currentTarget: String,
  dependencyTrackingMethod: DependencyTrackingMethod,
  unusedDepsMode: AnalyzerMode,
  strictDepsMode: AnalyzerMode,
  ignoredUnusedDependencyTargets: Set[String]
)

object OptionsParser {
  def create(
    options: List[String],
    error: String => Unit
  ): OptionsParser = {
    val optionsMap = mutable.Map[String, String]()
    options.foreach { option =>
      option.split(":", 2) match {
        case Array(key) =>
          error(s"Argument $key missing value")
        case Array(key, value) =>
          if (optionsMap.contains(key)) {
            error(s"Argument $key found multiple times")
          }
          optionsMap.put(key, value)
      }
    }

    new OptionsParser(error = error, options = optionsMap)
  }
}

class OptionsParser private(
  error: String => Unit,
  options: mutable.Map[String, String]
) {
  def failOnUnparsedOptions(): Unit = {
    options.keys.foreach { key =>
      error(s"Unrecognized option $key")
    }
  }

  def takeStringOpt(key: String): Option[String] = {
    options.remove(key)
  }

  def takeString(key: String): String = {
    takeStringOpt(key).getOrElse {
      error(s"Missing required option $key")
      "NA"
    }
  }

  def takeStringSeqOpt(key: String): Option[Seq[String]] = {
    takeStringOpt(key).map(_.split(":"))
  }
}

class DependencyAnalyzer(val global: Global) extends Plugin {

  override val name = "dependency-analyzer"
  override val description =
    "Analyzes the used dependencies. Can check and warn or fail the " +
      "compilation for issues including not directly including " +
      "dependencies which are directly included in the code, or " +
      "including unused dependencies."
  override val components = List[PluginComponent](Component)

  private val isWindows: Boolean = System.getProperty("os.name").toLowerCase.contains("windows")
  private var settings: DependencyAnalyzerSettings = null

  override def init(
    options: List[String],
    error: String => Unit
  ): Boolean = {
    val optionsParser = OptionsParser.create(options, error)

    def decodeTarget(target: String): String = {
      target.replace(";", ":")
    }

    def parseTargetSet(prefix: String): TargetSet = {
      new TargetSet(
        prefix = prefix,
        jarsSeq = optionsParser.takeStringSeqOpt(s"$prefix-jars").getOrElse(Seq.empty),
        targetsSeq = optionsParser.takeStringSeqOpt(s"$prefix-targets").map(_.map(decodeTarget)).getOrElse(Seq.empty)
      )
    }

    def extractAnalyzerMode(key: String): AnalyzerMode = {
      optionsParser
        .takeStringOpt(key)
        .map { str =>
          AnalyzerMode.parse(str).getOrElse {
            error(s"Failed to parse option $key")
            AnalyzerMode.Error
          }
        }
        .getOrElse(AnalyzerMode.Off)
    }

    settings =
      DependencyAnalyzerSettings(
        currentTarget = decodeTarget(optionsParser.takeString("current-target")),
        dependencyTrackingMethod =
          DependencyTrackingMethod
            .parse(optionsParser.takeString("dependency-tracking-method"))
            .getOrElse {
              error("Failed to parse option dependency-tracking-method")
              DependencyTrackingMethod.HighLevel
            },
        indirectTargetSet = parseTargetSet("indirect"),
        directTargetSet = parseTargetSet("direct"),
        unusedDepsMode = extractAnalyzerMode("unused-deps-mode"),
        strictDepsMode = extractAnalyzerMode("strict-deps-mode"),
        ignoredUnusedDependencyTargets =
          optionsParser
            .takeStringSeqOpt(s"unused-deps-ignored-targets")
            .getOrElse(Seq.empty)
            .map(decodeTarget)
            .toSet
      )
    optionsParser.failOnUnparsedOptions()
    true
  }

  private object Component extends PluginComponent {
    val global: DependencyAnalyzer.this.global.type =
      DependencyAnalyzer.this.global

    override val runsAfter = List("jvm")

    val phaseName = DependencyAnalyzer.this.name

    private def warnOrError(
      analyzerMode: AnalyzerMode,
      errors: Set[String]
    ): Unit = {
      val reportFunction: String => Unit = analyzerMode match {
        case AnalyzerMode.Error => global.reporter.error(global.NoPosition, _)
        case AnalyzerMode.Warn => global.reporter.warning(global.NoPosition, _)
        case AnalyzerMode.Off => _ => ()
      }

      errors.foreach(reportFunction)
    }

    override def newPhase(prev: Phase): StdPhase = new StdPhase(prev) {
      override def run(): Unit = {

        super.run()

        val usedJars = findUsedJars
        val usedJarPaths = if (!isWindows) usedJars.map(_.path) else usedJars.map(_.path.replaceAll("\\\\", "/"))

        if (settings.unusedDepsMode != AnalyzerMode.Off) {
          reportUnusedDepsFoundIn(usedJarPaths)
        }

        if (settings.strictDepsMode != AnalyzerMode.Off) {
          reportIndirectTargetsFoundIn(usedJarPaths)
        }
      }

      private def reportUnusedDepsFoundIn(usedJarPaths: Set[String]): Unit = {
        val directJarPaths = settings.directTargetSet.jarSet

        val usedTargets =
          usedJarPaths.flatMap(settings.directTargetSet.targetFromJarOpt)

        val unusedTargets = directJarPaths
          // This .get is safe because [jar] was gotten from [directJarPaths]
          // which is the set of keys of the direct targets.
          .filter(jar => !usedTargets.contains(settings.directTargetSet.targetFromJarOpt(jar).get))
          .flatMap(settings.directTargetSet.targetFromJarOpt)
          .diff(settings.ignoredUnusedDependencyTargets)

        val toWarnOrError =
          unusedTargets.map { target =>
            s"""Target '$target' is specified as a dependency to ${settings.currentTarget} but isn't used, please remove it from the deps.
               |You can use the following buildozer command:
               |buildozer 'remove deps $target' ${settings.currentTarget}
               |""".stripMargin
          }

        warnOrError(settings.unusedDepsMode, toWarnOrError)
      }

      private def reportIndirectTargetsFoundIn(usedJarPaths: Set[String]): Unit = {
        val errors =
          usedJarPaths
            .filterNot(settings.directTargetSet.jarSet.contains)
            .flatMap(settings.indirectTargetSet.targetFromJarOpt)
            .map { target =>
              s"""Target '$target' is used but isn't explicitly declared, please add it to the deps.
                 |You can use the following buildozer command:
                 |buildozer 'add deps $target' ${settings.currentTarget}""".stripMargin
            }

        warnOrError(settings.strictDepsMode, errors)
      }

      override def apply(unit: global.CompilationUnit): Unit = ()
    }

  }

  private def findUsedJars: Set[AbstractFile] = {
    settings.dependencyTrackingMethod match {
      case DependencyTrackingMethod.HighLevel =>
        findUsedJarsWithHighLevelCrawl
    }
  }

  import global.Symbol

  private def findUsedJarsWithHighLevelCrawl: Set[AbstractFile] = {
    val jars = collection.mutable.Set[AbstractFile]()

    def walkTopLevels(root: Symbol): Unit = {
      def safeInfo(sym: Symbol): global.Type =
        if (sym.hasRawInfo && sym.rawInfo.isComplete) sym.info else global.NoType

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

    global.exitingTyper {
      walkTopLevels(global.RootClass)
    }
    jars.toSet
  }
}
