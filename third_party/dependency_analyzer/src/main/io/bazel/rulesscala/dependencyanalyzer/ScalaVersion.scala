package io.bazel.rulesscala.dependencyanalyzer

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
   * Each of minVersionOpt and maxVersionOpt can either be None
   * to signify that there is no restriction on this bound,
   * or it can be a string of a full version number such as "2.12.10".
   *
   * When set to a version number, the bounds are inclusive.
   * For example, a maxVersion of "2.12.10" will accept version "2.12.10".
   *
   * Note only literal strings are accepted and inlined variables are accepted.
   * If any non-inlined variables are passed the code will fail to compile.
   * Inlined variables are generally those declared final on an object which
   * do not have a type attached.
   *
   * valid:
   *  conditional(Some("2.12.4"), None, "foo()")
   * invalid:
   *  conditional(MinVersionForFoo, None, "foo()")
   */
  def conditional(
    minVersionOpt: Option[String],
    maxVersionOpt: Option[String],
    code: String
  ): Unit =
    macro conditionalImpl

  def conditionalImpl(
    c: blackbox.Context
  )(
    minVersionOpt: c.Expr[Option[String]],
    maxVersionOpt: c.Expr[Option[String]],
    code: c.Expr[String]
  ): c.Tree = {
    import c.{universe => u}
    import u._

    // Due to non-deterministic code generation of quasiquotes, we do
    // not use them
    // See https://github.com/scala/bug/issues/11008
    // Eventually once we stop supporting all versions which don't have
    // the bugfix, we can use quasiquotes as desired

    def extractStringFromTree(tree: c.Tree): Option[String] = {
      tree match {
        case u.Literal(u.Constant(s: String)) =>
          Some(s)
        case _ =>
          None
      }
    }

    def extractStringOption(expr: c.Expr[Option[String]]): Option[String] = {
      expr.tree match {
        case u.Apply(
          u.TypeApply(
            u.Select(u.Select(u.Ident(u.TermName("scala")), u.TermName("Some")), u.TermName("apply")),
            List(u.TypeTree())),
          str :: Nil
        ) if extractStringFromTree(str).nonEmpty =>
          extractStringFromTree(str)
        case u.Select(u.Ident(u.TermName("scala")), u.TermName("None")) =>
          None
        case _ =>
          c.error(
            expr.tree.pos,
            "Parameter must be passed as an Option[String] literal such as " +
              "Some(\"2.12.10\") or None")
          None
      }
    }

    def extractString(expr: c.Expr[String]): String = {
      extractStringFromTree(expr.tree).getOrElse {
        c.error(
          expr.tree.pos,
          "Parameter must be passed as a string literal such as \"2.12.10\"")
        ""
      }
    }

    val meetsMinVersionRequirement = {
      val minVersionOptValue = extractStringOption(minVersionOpt)

      // Note: Unit tests do not test that this bound is inclusive rather
      // than exclusive so be careful when changing this code not to
      // accidentally make this an exclusive bound (see ScalaVersionTest for
      // details)
      minVersionOptValue.forall(version => Current >= ScalaVersion(version))
    }

    val meetsMaxVersionRequirement = {
      val maxVersionOptValue = extractStringOption(maxVersionOpt)
      // Note: Unit tests do not test that this bound is inclusive rather
      // than exclusive so be careful when changing this code not to
      // accidentally make this an exclusive bound (see ScalaVersionTest for
      // details)
      maxVersionOptValue.forall(version => Current <= ScalaVersion(version))
    }

    if (meetsMinVersionRequirement && meetsMaxVersionRequirement) {
      c.parse(extractString(code))
    } else {
      u.EmptyTree
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
