package io.bazel.rulesscala.dependencyanalyzer

import scala.annotation.tailrec
import scala.util.Using

object ScalaVersion {
  val Current: ScalaVersion = {
    def props(url: java.net.URL): java.util.Properties = {
      val properties = new java.util.Properties()
      Using(url.openStream())(properties.load)
      properties
    }

    def scala2Version: String = props(getClass.getResource("/library.properties")).getProperty("version.number")

    @tailrec def checkScala3(res: java.util.Enumeration[java.net.URL]): String =
      if !res.hasMoreElements then scala2Version
      else
        val manifest = props(res.nextElement)
        manifest.getProperty("Specification-Title") match
          case "scala3-library-bootstrapped" => manifest.getProperty("Implementation-Version")
          case _ => checkScala3(res)

    val manifests = getClass.getClassLoader.getResources("META-INF/MANIFEST.MF")

    ScalaVersion(checkScala3(manifests))
  }

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
