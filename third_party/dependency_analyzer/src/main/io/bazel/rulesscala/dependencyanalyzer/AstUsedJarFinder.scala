package third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer

import scala.reflect.io.AbstractFile
import scala.tools.nsc.Global

class AstUsedJarFinder(
  global: Global
) {
  import global._

  def findUsedJars: Set[AbstractFile] = {
    val jars = collection.mutable.Set[AbstractFile]()

    def handleType(tpe: Type): Unit = {
      val sym = tpe.typeSymbol
      val assocFile = sym.associatedFile
      if (assocFile.path.endsWith(".class"))
        assocFile.underlyingSource.foreach { source =>
          jars.add(source)
        }
    }

    def exploreType(tpe: Type): Unit = {
      handleType(tpe)
      tpe.typeArgs.foreach(exploreType)
    }

    def fullyExploreTree(tree: Tree): Unit = {
      exploreTree(tree)
      tree.foreach(exploreTree)
    }

    def exploreTree(tree: Tree): Unit = {
      tree match {
        case node: TypeTree =>
          if (node.original != null) {
            node.original.foreach(fullyExploreTree)
          }
        case node: Literal =>
          node.value.value match {
            case tpe: Type =>
              exploreType(tpe)
            case _ =>
          }
        case _ =>
      }

      val shouldExamine =
        tree match {
          case select: Select if select.symbol.isDefaultGetter =>
            false
          case _ =>
            true
        }

      if (shouldExamine) {
        if (tree.hasSymbolField) {
          tree.symbol.annotations.foreach { annot =>
            annot.tree.foreach(fullyExploreTree)
          }
        }
        if (tree.tpe != null) {
          exploreType(tree.tpe)
        }
      }
    }

    currentRun.units.foreach { unit =>
      unit.body.foreach(fullyExploreTree)
    }
    jars.toSet
  }
}
