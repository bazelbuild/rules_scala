package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.io.AbstractFile
import dotty.tools.dotc.util.{NoSourcePosition, SourcePosition}
import dotty.tools.dotc.core.Contexts.{Context, atPhase, ctx}
import dotty.tools.dotc.core.{Flags, Phases}
import dotty.tools.dotc.core.Symbols.Symbol
import dotty.tools.dotc.core.Types.Type

import scala.collection.mutable

class HighLevelCrawlUsedJarFinder:

  def findUsedJars(using Context): Map[AbstractFile, SourcePosition] =
    val jars = mutable.Set.empty[AbstractFile]
    // Execute at first transform phases which happens after inlining and macros splicing (interpretation)
    atPhase(Phases.firstTransformPhase) {
      walkTopLevels(ctx.definitions.RootClass, jars)
    }
    jars.map(_ -> NoSourcePosition).toMap

  private def walkTopLevels(root: Symbol, jars: mutable.Set[AbstractFile])(using Context): Unit = {
    def packageClassOrSelf(sym: Symbol): Symbol =
      if sym.is(Flags.Package, butNot = Flags.ModuleClass) then sym.moduleClass
      else sym

    for
      lazyType <- packageClassOrSelf(root).unforcedInfo
      sym <- lazyType.decls
    do {
      if sym == root then ()
      else if sym.is(Flags.Package) then walkTopLevels(sym, jars)
      else if sym.owner != root then { // exclude package class members
        val assocFile = sym.associatedFile
        if assocFile != null then
          val path = assocFile.path
          if path.isClassFile || path.isTastyFile then
            jars ++= assocFile.underlyingSource // the jar
              .orElse(Some(assocFile)) // or .class/.tasty file otherwise
      }
    }
  }

