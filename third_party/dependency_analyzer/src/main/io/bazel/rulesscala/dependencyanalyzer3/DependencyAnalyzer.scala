package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.dotc.ast.Trees.*
import dotty.tools.dotc.ast.tpd
import dotty.tools.dotc.core.Constants.Constant
import dotty.tools.dotc.core.Contexts.Context
import dotty.tools.dotc.core.Decorators.*
import dotty.tools.dotc.core.StdNames.*
import dotty.tools.dotc.core.Symbols.*
import dotty.tools.dotc.plugins.{PluginPhase, StandardPlugin}
import dotty.tools.dotc.transform.{Pickler, Staging}

class DependencyAnalyzer extends StandardPlugin:
  override val name: String = "dependency-analyzer"
  override val description: String =
    "Analyzes the used dependencies. Can check and warn or fail the " +
    "compilation for issues including not directly including " +
    "dependencies which are directly included in the code, or " +
    "including unused dependencies."

  def init(options: List[String]): List[PluginPhase] =
    (new DependencyAnalyzerPhase) :: Nil

class DependencyAnalyzerPhase extends PluginPhase:
  import tpd.*

  val phaseName = "dependecy-analyzer-phase"

  override val runsAfter = Set(Pickler.name)
  override val runsBefore = Set(Staging.name)

  override def transformApply(tree: Apply)(implicit ctx: Context): Tree =
    tree