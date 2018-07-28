package third_party.utils.src.main.io.bazel.rulesscala.utils

import scala.reflect.io.AbstractFile
import scala.tools.nsc.Global

object Utils {
  sealed trait AnalyzerMode
  case object Error extends AnalyzerMode
  case object Warn extends AnalyzerMode

  def parseAnalyzerMode(mode: String): Option[AnalyzerMode] = mode match {
    case "error" => Some(Error)
    case "warn" => Some(Warn)
    case _ => None
  }

  def decodeTarget(target: String): String = target.replace(";", ":")

  def findUsedJars(global: Global): Set[AbstractFile] = {
    import global._

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
