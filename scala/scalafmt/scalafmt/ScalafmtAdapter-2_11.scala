package io.bazel.rules_scala.scalafmt

import java.io.File
import org.scalafmt.config.Config
import org.scalafmt.config.ScalafmtConfig
import org.scalafmt.util.FileOps

object ScalafmtAdapter {
    def readFile(file: File)(implicit codec: scala.io.Codec): String =
        FileOps.readFile(file)(codec)

    def parseConfigFile(configFile: File): ScalafmtConfig =
        Config.fromHoconFile(configFile).get
}
