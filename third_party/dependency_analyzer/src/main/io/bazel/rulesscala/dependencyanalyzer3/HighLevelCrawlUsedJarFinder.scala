package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.dotc.ast.Trees.{Apply, Untyped}
import dotty.tools.dotc.core.Contexts._
import dotty.tools.dotc.core.Denotations._
import dotty.tools.dotc.util.{NoSourcePosition, SourcePosition}
import dotty.tools.io.AbstractFile

class HighLevelCrawlUsedJarFinder() {
  def findUsedJars[T >: Untyped](tree: Apply[T])(implicit ctx: Context): Map[AbstractFile, SourcePosition] = {
    val jars = collection.mutable.Set[AbstractFile]()

    walkTopLevels(tree.fun.denot, jars)

    jars.map(jar => jar -> NoSourcePosition).toMap
  }

  private def walkTopLevels(root: Denotation, jars: collection.mutable.Set[AbstractFile])(implicit ctx: Context) : Unit = {

  }
}
