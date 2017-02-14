package io.bazel.rulesscala.worker;

import com.google.devtools.build.lib.worker.WorkerProtocol.WorkRequest;
import com.google.devtools.build.lib.worker.WorkerProtocol.WorkResponse;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.lang.reflect.Field;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.util.Map.Entry;
import java.util.Map;
import java.util.TreeMap;
import static java.nio.charset.StandardCharsets.UTF_8;

public class GenericWorker {
  final protected Processor processor;

  public GenericWorker(Processor p) {
    processor = p;
  }

  protected void setupOutput(PrintStream ps) {
    System.setOut(ps);
    System.setErr(ps);
  }

  // Mostly lifted from bazel
  private void runPersistentWorker() throws IOException {
    PrintStream originalStdOut = System.out;
    PrintStream originalStdErr = System.err;

    while (true) {
      try {
        WorkRequest request = WorkRequest.parseDelimitedFrom(System.in);
        if (request == null) {
          break;
        }
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        int exitCode = 0;

        try (PrintStream ps = new PrintStream(baos)) {
          setupOutput(ps);

          try {
            processor.processRequest(request.getArgumentsList());
          } catch (Exception e) {
            e.printStackTrace();
            exitCode = 1;
          }
        } finally {
          System.setOut(originalStdOut);
          System.setErr(originalStdErr);
        }

        WorkResponse.newBuilder()
            .setOutput(baos.toString())
            .setExitCode(exitCode)
            .build()
            .writeDelimitedTo(System.out);
        System.out.flush();
      } finally {
        System.gc();
      }
    }
  }

  public static <T> String[] appendToString(String[] init, List<T> rest) {
    String[] tmp = new String[init.length + rest.size()];
    System.arraycopy(init, 0, tmp, 0, init.length);
    int baseIdx = init.length;
    for(T t : rest) {
      tmp[baseIdx] = t.toString();
      baseIdx += 1;
    }
    return tmp;
  }
  public static String[] merge(String[]... arrays) {
    int totalLength = 0;
    for(String[] arr:arrays){
      totalLength += arr.length;
    }

    String[] result = new String[totalLength];
    int offset = 0;
    for(String[] arr:arrays){
      System.arraycopy(arr, 0, result, offset, arr.length);
      offset += arr.length;
    }
    return result;
  }

  private boolean contains(String[] args, String s) {
    for (String str : args) {
      if (str.equals(s)) return true;
    }
    return false;
  }


  private static List<String> normalize(List<String> args) throws IOException {
    if (args.size() == 1 && args.get(0).startsWith("@")) {
      return Files.readAllLines(Paths.get(args.get(0).substring(1)), UTF_8);
    }
    else {
      return args;
    }
  }

  /**
   * This is expected to be called by a main method
   */
  public void run(String[] argArray) {
    try {
      if (contains(argArray, "--persistent_worker")) {
        runPersistentWorker();
      }
      else {
        List<String> args = Arrays.asList(argArray);
        processor.processRequest(normalize(args));
      }
    }
    catch (Exception ex) {
      throw new RuntimeException("nope", ex);
    }
  }
}
