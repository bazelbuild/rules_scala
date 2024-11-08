package io.bazel.rulesscala.dependencyanalyzer

import scala.annotation.tailrec
import scala.util.Using
import dotty.tools.dotc

object ScalaVersion {
  val Current: ScalaVersion = dotc.config.Properties.scalaPropOrNone("version.number")
    .map(ScalaVersion(_))
    .getOrElse(sys.error("Failed to resolve version of Scala"))

  def apply(versionString: String): ScalaVersion = {
    versionString.split('.').take(3) match {
      case Array(superMajor, major, minor) => new ScalaVersion(superMajor.toInt, major.toInt, minor.toInt)
      case _ => throw new Exception(s"Failed to parse version $versionString")
    }
  }
}

case class ScalaVersion private (major: Int, minor: Int, patch: Int) extends Ordered[ScalaVersion] {
  override def compare(that: ScalaVersion): Int = that match {
    case ScalaVersion(`major`, `minor`, _) => this.patch.compareTo(that.patch)
    case ScalaVersion(`major`, _, _) => this.minor.compareTo(that.minor)
    case _ => this.major.compareTo(that.major)
  }

  override def toString: String = s"$major.$minor.$patch"
}
