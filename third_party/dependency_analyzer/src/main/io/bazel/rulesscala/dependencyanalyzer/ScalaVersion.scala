package third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer

import scala.language.experimental.macros
import scala.reflect.macros.blackbox

object ScalaVersion {
  val Current: ScalaVersion = ScalaVersion(util.Properties.versionNumberString)

  def apply(versionString: String): ScalaVersion = {
    versionString.split("\\.") match {
      case Array(superMajor, major, minor) =>
        new ScalaVersion(superMajor.toInt, major.toInt, minor.toInt)
      case _ =>
        throw new Exception(s"Failed to parse version $versionString")
    }
  }

  /**
   * Runs [code] only if minVersion and maxVersion constraints are met.
   *
   * NOTE: This method should be used only rarely. Most of the time
   * just comparing versions in code should be enough. This is needed
   * only when the code we want to run can't compile under certain
   * versions. The reason to use this rarely is the API's inflexibility
   * and the difficulty in debugging this code.
   *
   * Each of minVersion and maxVersion can either be the empty string ("")
   * to signify that there is no restriction on this bound.
   *
   * Or it can be a string of a full version number such as "2.12.10".
   *
   * Note only literal strings are accepted, no variables etc. i.e.
   *
   * valid:
   *  conditional(minVersion = "2.12.4", maxVersion = "", code = "foo()")
   * invalid:
   *  conditional(minVersion = MinVersionForFoo, maxVersion = "", code = "foo()")
   */
  def conditional(
    minVersion: String,
    maxVersion: String,
    code: String
  ): Unit =
    macro conditionalImpl

  def conditionalImpl(
    c: blackbox.Context
  )(
    minVersion: c.Expr[String],
    maxVersion: c.Expr[String],
    code: c.Expr[String]
  ): c.Tree = {
    import c.{universe => u}
    import u.Quasiquote
    def extractString(expr: c.Expr[String]): String = {
      expr.tree match {
        case u.Literal(u.Constant(s: String)) =>
          s
        case _ =>
          c.error(
            expr.tree.pos,
            "Parameter must be passed as a string literal such as \"2.12.10\"")
          ""
      }
    }

    val meetsMinVersionRequirement = {
      val minVersionStr = extractString(minVersion)
      minVersionStr == "" || Current >= ScalaVersion(minVersionStr)
    }

    val meetsMaxVersionRequirement = {
      val maxVersionStr = extractString(maxVersion)
      maxVersionStr == "" || Current <= ScalaVersion(maxVersionStr)
    }

    if (meetsMinVersionRequirement && meetsMaxVersionRequirement) {
      c.parse(extractString(code))
    } else {
      q""
    }
  }
}

class ScalaVersion private(
  private val superMajor: Int,
  private val major: Int,
  private val minor: Int
) extends Ordered[ScalaVersion] {
  override def compare(that: ScalaVersion): Int = {
    if (this.superMajor != that.superMajor) {
      this.superMajor.compareTo(that.superMajor)
    } else if (this.major != that.major) {
      this.major.compareTo(that.major)
    } else {
      this.minor.compareTo(that.minor)
    }
  }

  override def equals(obj: Any): Boolean = {
    obj match {
      case that: ScalaVersion =>
        compare(that) == 0
      case _ =>
        false
    }
  }

  override def toString: String = {
    s"$superMajor.$major.$minor"
  }
}
