package io.bazel.rulesscala.dependencyanalyzer

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
  case object HighLevel extends DependencyTrackingMethod("high-level")

  /**
   * Discovers dependencies by crawling the AST.
   */
  case object Ast extends DependencyTrackingMethod("ast")

  def parse(mode: String): Option[DependencyTrackingMethod] = {
    Seq(HighLevel, Ast).find(_.name == mode)
  }
}

sealed abstract class DependencyTrackingMethod(val name: String)

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

object DependencyAnalyzerSettings {
  def parseSettings(
    options: List[String],
    error: String => Unit
  ): DependencyAnalyzerSettings = {

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
            error(s"Failed to parse option $key with value $str")
            AnalyzerMode.Error
          }
        }
        .getOrElse(AnalyzerMode.Off)
    }

    val settings =
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
            .takeStringSeqOpt("unused-deps-ignored-targets")
            .getOrElse(Seq.empty)
            .map(decodeTarget)
            .toSet
      )
    optionsParser.failOnUnparsedOptions()
    settings
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
