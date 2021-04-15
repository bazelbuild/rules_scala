package io.bazel.rulesscala.dependencyanalyzer

import scala.reflect.io.AbstractFile
import scala.tools.nsc.Global

class HighLevelCrawlUsedJarFinder(
  global: Global
) {
  import global.Symbol

  def findUsedJars: Map[AbstractFile, Usage] = {
    val jars = collection.mutable.Set[AbstractFile]()

    global.exitingTyper {
      walkTopLevels(global.RootClass, jars)
    }
    jars.map(jar => jar -> Usage(global.NoPosition, Direct)).toMap
  }

  private def walkTopLevels(root: Symbol, jars: collection.mutable.Set[AbstractFile]): Unit = {
    def safeInfo(sym: Symbol): global.Type =
      if (sym.hasRawInfo && sym.rawInfo.isComplete) sym.info else global.NoType

    def packageClassOrSelf(sym: Symbol): Symbol =
      if (sym.hasPackageFlag && !sym.isModuleClass) sym.moduleClass else sym

    for (x <- safeInfo(packageClassOrSelf(root)).decls) {
      if (x == root) ()
      else if (x.hasPackageFlag) walkTopLevels(x, jars)
      else if (x.owner != root) { // exclude package class members
        if (x.hasRawInfo && x.rawInfo.isComplete) {
          val assocFile = x.associatedFile
          if (assocFile.path.endsWith(".class") && assocFile.underlyingSource.isDefined)
            assocFile.underlyingSource.foreach(jars += _)
        }
      }
    }
  }
}
