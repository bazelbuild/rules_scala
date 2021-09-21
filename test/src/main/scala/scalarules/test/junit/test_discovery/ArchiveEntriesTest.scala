package io.bazel.rulesscala.test_discovery

import io.bazel.rulesscala.test_discovery.ArchiveEntries.listClassFiles
import org.specs2.mutable.SpecWithJUnit

import java.io.File
import java.nio.file.Files

class ArchiveEntriesTest extends SpecWithJUnit {
  "List only class files from a directory" in {
    val dir = Files.createTempDirectory("temp")
    Files.createFile(dir.resolve("SomeFile"))
    Files.createFile(dir.resolve("Another.class"))

    listClassFiles(dir.toFile) must containTheSameElementsAs(Seq("Another.class"))
  }

  "List only class files from a jar file" in {
    val archives = System.getProperty("bazel.discover.classes.archives.file.paths").split(",")
    val thisTestJar = archives.head

    val expectedClassFile = "io/bazel/rulesscala/test_discovery/ArchiveEntriesTest.class"
    listClassFiles(new File(thisTestJar)) must containTheSameElementsAs(Seq(expectedClassFile))
  }
}
