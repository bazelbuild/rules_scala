package io.bazel.rulesscala.exe;

import com.google.common.base.Preconditions;
import com.google.common.io.ByteStreams;
import com.google.devtools.build.runfiles.Runfiles;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Arrays;
import java.util.List;


public class LauncherFileWriter {
  public static void main(String[] args) throws IOException {
    Preconditions.checkArgument(args.length == 6);

    final String location = args[0];
    final String workspaceName = args[1];
    final String javaBinPath = args[2];
    final String jarBinPath = javaBinPath.substring(0, javaBinPath.lastIndexOf('/')) + "/jar.exe";
    final String javaStartClass = args[3];
    final String cpFile = args[4];
    final List<String> jvmFlags = Arrays.asList(args[5].split(";"));
    final String classpath = Files.readAllLines(Paths.get(cpFile)).get(0);

    LaunchInfo launchInfo =
        LaunchInfo.builder()
            .addKeyValuePair("binary_type", "Java")
            .addKeyValuePair("workspace_name", workspaceName)
            .addKeyValuePair("symlink_runfiles_enabled", "0")
            .addKeyValuePair("java_bin_path", workspaceName + "/" + javaBinPath)
            .addKeyValuePair("jar_bin_path", jarBinPath)
            .addKeyValuePair("java_start_class", javaStartClass)
            .addKeyValuePair("classpath", classpath)
            .addJoinedValues("jvm_flags", " ", jvmFlags)
            .build();

    Path launcher = Paths.get(Runfiles.create().rlocation("bazel_tools/tools/launcher/launcher.exe"));
    Path outPath = Paths.get(location);

    try (InputStream in = Files.newInputStream(launcher); OutputStream out = Files.newOutputStream(outPath)) {
      ByteStreams.copy(in, out);

      long dataLength = launchInfo.write(out);
      ByteBuffer buffer = ByteBuffer.allocate(Long.BYTES);
      buffer.order(ByteOrder.LITTLE_ENDIAN);
      buffer.putLong(dataLength);
      out.write(buffer.array());

      out.flush();
    }
  }
}
