package io.bazel.rulesscala.exe;

import com.google.devtools.build.runfiles.Runfiles;
import io.bazel.rulesscala.io_utils.StreamCopy;
import io.bazel.rulesscala.preconditions.Preconditions;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.*;
import java.util.Arrays;
import java.util.List;
import java.nio.file.Paths;

public class LauncherFileWriter {
  public static void main(String[] args) throws IOException {
    Preconditions.require(args.length == 6);

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
            .addKeyValuePair("java_bin_path", javaBinPath.replace("\\", "/")) //Expects rlocationpath (i.e. with prepended repo name)
            .addKeyValuePair("jar_bin_path", rlocationpath_to_rootpath( workspaceName, jarBinPath)) //Expects rootpath location 
            .addKeyValuePair("java_start_class", javaStartClass)
            .addKeyValuePair("classpath", classpath) //Expects rootpath location
            .addJoinedValues("jvm_flags", "\t", jvmFlags)
            .build();

    Path launcher =
        Paths.get(Runfiles.create().rlocation("bazel_tools/tools/launcher/launcher.exe"));
    Path outPath = Paths.get(location);

    try (InputStream in = Files.newInputStream(launcher);
        OutputStream out = Files.newOutputStream(outPath)) {
      StreamCopy.copy(in, out);

      long dataLength = launchInfo.write(out);
      ByteBuffer buffer = ByteBuffer.allocate(Long.BYTES);
      buffer.order(ByteOrder.LITTLE_ENDIAN);
      buffer.putLong(dataLength);
      out.write(buffer.array());

      out.flush();
    }
  }

  //Bazel's java_launcher expects some fields(i.e. jar_bin_path and classpaths) to be rootpath. rlocationpath is relative to runfiledir (always prefix with repo). Rootpath is relative to runfiledir/workspacename. 
  static String rlocationpath_to_rootpath(String workspaceName, String rlocationpath){
    Path path = Paths.get(rlocationpath);

    Path result;
    if(!path.startsWith(workspaceName)){
      //Assume that if its not in the main workspace, that it is an external repo (and should be one level down)
      result = Paths.get("../").resolve(path);
    }else{
      result = Paths.get(workspaceName).resolve(path);
    }
    return result.toString().replace("\\", "/");
  }
}
