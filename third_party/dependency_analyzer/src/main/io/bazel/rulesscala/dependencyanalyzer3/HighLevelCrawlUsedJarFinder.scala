package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.dotc.ast.Trees.{Apply, Untyped}
import dotty.tools.dotc.core.Symbols._
import dotty.tools.dotc.core.Denotations._
import dotty.tools.dotc.core.Flags._
import dotty.tools.dotc.core.Contexts._
import dotty.tools.dotc.util.{NoSourcePosition, SourcePosition}
import dotty.tools.io.AbstractFile

class HighLevelCrawlUsedJarFinder() {
  def findUsedJars[T >: Untyped](tree: Apply[T])(implicit ctx: Context): Map[AbstractFile, SourcePosition] = {
    val jars = collection.mutable.Set[AbstractFile]()

    walkTopLevels(tree.fun.denot, jars)

    jars.map(jar => jar -> NoSourcePosition).toMap
  }

  private def walkTopLevels(root: Denotation, jars: collection.mutable.Set[AbstractFile])(implicit ctx: Context) : Unit = {
    def safeInfo(denotation: Denotation): Type =
      denotation.info

    def packageClassOrSelf(denotation: Denotation): Denotation =
      if ((denotation.symbol is Package) && !(denotation.symbol is ModuleClass)) denotation.symbol.moduleClass else denotation

    for (scope <- safeInfo(packageClassOrSelf(root)).decls) {

      if (scope == root.symbol) ()
      else if (scope is Package) walkTopLevels(scope, jars)
      else if (scope.owner != root.symbol) { // exclude package class members
        //if (x.hasRawInfo && x.rawInfo.isComplete) {
          val assocFile = scope.associatedFile
          if (assocFile.path.endsWith(".class") && assocFile.underlyingSource.isDefined)
            assocFile.underlyingSource.foreach(jars += _)
        //}
      }
    }
  }
}
