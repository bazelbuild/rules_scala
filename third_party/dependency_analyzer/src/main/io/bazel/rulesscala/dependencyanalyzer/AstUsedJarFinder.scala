package third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer

import scala.reflect.io.AbstractFile
import scala.tools.nsc.Global

class AstUsedJarFinder(
  global: Global
) {
  import global._

  def findUsedJars: Map[AbstractFile, Global#Position] = {
    val jars = collection.mutable.Map[AbstractFile, global.Position]()

    def recordUse(source: AbstractFile, pos: Position): Unit = {
      // We prefer to report locations which have information (e.g.
      // we don't want NoPosition).
      if (!jars.contains(source) || !jars(source).isDefined) {
        jars.put(source, pos)
      }
    }

    def handleType(tpe: Type, pos: Position): Unit = {
      val sym = tpe.typeSymbol
      val assocFile = sym.associatedFile
      if (assocFile.path.endsWith(".class"))
        assocFile.underlyingSource.foreach { source =>
          recordUse(source, pos)
        }
    }

    def exploreType(tpe: Type, pos: Position): Unit = {
      handleType(tpe, pos)
      tpe.typeArgs.foreach(exploreType(_, pos))
    }

    def fullyExploreTree(tree: Tree): Unit = {
      exploreTree(tree)
      tree.foreach(exploreTree)
    }

    def exploreClassfileAnnotArg(arg: ClassfileAnnotArg, pos: Position): Unit = {
      arg match {
        case LiteralAnnotArg(value) =>
          exploreConstant(value, pos)
        case ArrayAnnotArg(args) =>
          args.foreach(exploreClassfileAnnotArg(_, pos))
        case NestedAnnotArg(info) =>
          exploreAnnotationInfo(info)
        case _ =>
      }
    }
    def exploreAnnotationInfo(annot: AnnotationInfo): Unit = {
      // It would be nice if we could just do
      //    fullyExploreTree(annot.tree)
      // Unfortunately that tree is synthetic and hence doesn't have
      // positions attached. Hence we examine the components that
      // go into that tree separately, as those do have positions.
      exploreType(annot.tpe, annot.pos)
      annot.scalaArgs.foreach(fullyExploreTree)
      annot.javaArgs.values.foreach(exploreClassfileAnnotArg(_, annot.pos))
    }

    def exploreConstant(value: Constant, pos: Position): Unit = {
      value.value match {
        case tpe: Type =>
          exploreType(tpe, pos)
        case _ =>
      }
    }

    def exploreTree(tree: Tree): Unit = {
      tree match {
        case node: TypeTree =>
          if (node.original != null) {
            node.original.foreach(fullyExploreTree)
          }
        case node: Literal =>
          // We should examine OriginalTreeAttachment but that was only
          // added in 2.12.4, so include a version check
          ScalaVersion.conditional(
            Some("2.12.4"),
            None,
            """
              node.attachments
                .get[global.treeChecker.OriginalTreeAttachment]
                .foreach { attach =>
                  fullyExploreTree(attach.original)
                }
            """
          )

          exploreConstant(node.value, tree.pos)
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
          tree.symbol.annotations.foreach(exploreAnnotationInfo)
        }
        if (tree.tpe != null) {
          exploreType(tree.tpe, tree.pos)
        }
      }
    }

    currentRun.units.foreach { unit =>
      unit.body.foreach(fullyExploreTree)
    }
    jars.toMap
  }
}
