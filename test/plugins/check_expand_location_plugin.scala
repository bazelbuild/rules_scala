package plugin

import scala.tools.nsc.Global
import scala.tools.nsc.Phase
import scala.tools.nsc.plugins.{ Plugin => NscPlugin}
import scala.tools.nsc.plugins.PluginComponent

import java.io.File

final class Plugin(override val global: Global) extends NscPlugin {
  override val name: String = "diablerie"
  override val description: String = "just another plugin"
  override val components: List[PluginComponent] = Nil

  override def processOptions(options: List[String], error: String => Unit): Unit = {
    options
      .find(_.startsWith("location="))
      .map(_.stripPrefix("location="))
      .map(v => new File(v).exists) match {
        case Some(true) => ()
        case Some(false) => error("expanded location doesn't exist")
        case None => error("missing location argument")
      }
  }
}
