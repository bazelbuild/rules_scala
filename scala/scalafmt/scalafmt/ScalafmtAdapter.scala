package io.bazel.rules_scala.scalafmt

import java.io.File
import org.scalafmt.config.ScalafmtConfig
import org.scalafmt.sysops.PlatformFileOps

object ScalafmtAdapter {
    def readFile(file: File)(implicit codec: scala.io.Codec): String =
        PlatformFileOps.readFile(file.toPath())(codec)

    def parseConfigFile(configFile: File): ScalafmtConfig =
        ScalafmtConfig.fromHoconFile(configFile.toPath()).get
}
