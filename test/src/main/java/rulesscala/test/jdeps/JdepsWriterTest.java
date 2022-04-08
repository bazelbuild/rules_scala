package jdeps;

import static org.junit.Assert.assertArrayEquals;

import com.google.devtools.build.lib.view.proto.Deps;
import com.google.devtools.build.lib.view.proto.Deps.Dependency;
import io.bazel.rulesscala.jdeps.JdepsWriter;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import org.junit.Test;

public class JdepsWriterTest {

  @Test
  public void writesJarListToJdepsFile() throws IOException {
    File jdepsPath = Files
        .createTempDirectory("jdeps-test-tempdir-")
        .resolve("some-target.jdeps")
        .toFile();

    String[] classpath = {"foo.jar", "baz/zoo.class"};

    JdepsWriter.write(
        jdepsPath.getPath(),
        "some-target",
        classpath
    );

    assertArrayEquals(readJarsFromJdepsFile(jdepsPath), classpath);
  }

  private String[] readJarsFromJdepsFile(File jdepsPath) throws IOException {
    Deps.Dependencies dependencies = Deps.Dependencies
        .parseFrom(new BufferedInputStream(new FileInputStream(jdepsPath)));

    return dependencies
        .getDependencyList()
        .stream()
        .map(Dependency::getPath)
        .toArray(String[]::new);
  }
}