package io.bazel.rulesscala.jdeps;

import com.google.devtools.build.lib.view.proto.Deps;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class JdepsWriter {

  public static void write(String jdpesPath, String currentTarget, String[] classpath)
      throws IOException {

    Deps.Dependencies.Builder builder = Deps.Dependencies.newBuilder();
    builder.setSuccess(true);
    builder.setRuleLabel(currentTarget);

    for (String jar : classpath) {
      Deps.Dependency.Builder dependencyBuilder = Deps.Dependency.newBuilder();
      dependencyBuilder.setKind(Deps.Dependency.Kind.EXPLICIT);
      dependencyBuilder.setPath(jar);
      builder.addDependency(dependencyBuilder.build());
    }

    try (OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(jdpesPath))) {
      outputStream.write(builder.build().toByteArray());
    }
  }

}
