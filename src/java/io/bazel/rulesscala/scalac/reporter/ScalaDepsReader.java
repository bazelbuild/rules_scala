package io.bazel.rulesscala.scalac.reporter;

import io.bazel.rulesscala.deps.proto.ScalaDeps;
import io.bazel.rulesscala.deps.proto.ScalaDeps.Dependencies;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;

public class ScalaDepsReader {

  public static void main(String[] args) throws IOException {
    try (InputStream is = Files.newInputStream(Paths.get(args[0]))) {
      Dependencies dependencies = Dependencies.parseFrom(is);

      for (ScalaDeps.Dependency dep : dependencies.getDependencyList()) {
        System.out.println(dep.getLabel() + "," + dep.getIjarPath() + "," + dep.getPath() + "," + dep.getKind() + "," + dep.getIgnored());
      }
    }
  }
}
