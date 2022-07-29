package io.bazel.rulesscala.scala_test;

import com.google.devtools.build.runfiles.Runfiles;
import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;

/**
 * This exists only as a proxy for scala tests's runner to: - provide access to env variables -
 * unwrap runner's arguments from a file (passed via file to overcome command-line string limitation
 * on Windows)
 */
public class Runner {
  /**
   * This is the name of the env var set by bazel when a user provides a `--test_filter` test option
   */
  private static final String TESTBRIDGE_TEST_ONLY = "TESTBRIDGE_TEST_ONLY";

  /** This is the name of the system property used to pass the main workspace name */
  private static final String RULES_SCALA_MAIN_WS_NAME = "RULES_SCALA_MAIN_WS_NAME";

  /**
   * This is the name of the system property used to pass a short path of the file, which includes
   * <code>org.scalatest.tools.Runner</code> arguments
   */
  private static final String RULES_SCALA_ARGS_FILE = "RULES_SCALA_ARGS_FILE";

  public static void main(String[] args) throws IOException {
    org.scalatest.tools.Runner.main(extendArgs(args, System.getenv()));
  }

  private static String[] extendArgs(String[] args, Map<String, String> env) throws IOException {
    args = extendFromFileArgs(args);
    args = prependFromEnvVar(args, env, TESTBRIDGE_TEST_ONLY, "-s");
    return args;
  }

  private static String[] extendFromFileArgs(String[] args) throws IOException {
    String runnerArgsFileKey = System.getProperty(RULES_SCALA_ARGS_FILE);
    if (runnerArgsFileKey == null || runnerArgsFileKey.trim().isEmpty())
      throw new IllegalArgumentException(RULES_SCALA_ARGS_FILE + " is null or empty.");

    String workspace = System.getProperty(RULES_SCALA_MAIN_WS_NAME);
    if (workspace == null || workspace.trim().isEmpty())
      throw new IllegalArgumentException(RULES_SCALA_MAIN_WS_NAME + " is null or empty.");

    String runnerArgsFilePath = Runfiles.create().rlocation(workspace + "/" + runnerArgsFileKey);
    if (runnerArgsFilePath == null)
      throw new IllegalArgumentException("rlocation value is null for key: " + runnerArgsFileKey);

    List<String> runnerArgs =
        Files.readAllLines(Paths.get(runnerArgsFilePath), Charset.forName("UTF-8"));
    rlocateRunpathValue(workspace, runnerArgs);

    String[] runnerArgsArray = runnerArgs.toArray(new String[runnerArgs.size()]);

    String[] result = new String[args.length + runnerArgsArray.length];
    System.arraycopy(args, 0, result, 0, args.length);
    System.arraycopy(runnerArgsArray, 0, result, args.length, runnerArgsArray.length);

    return result;
  }

  private static String[] prependFromEnvVar(
      String[] args, Map<String, String> env, String varName, String flagName) {
    String value = env.get(varName);
    if (value == null) {
      return args;
    }
    String[] flag = new String[] {flagName, value};
    String[] result = new String[args.length + flag.length];
    System.arraycopy(flag, 0, result, 0, flag.length);
    System.arraycopy(args, 0, result, flag.length, args.length);

    return result;
  }

  /**
   * Replaces ScalaTest Runner's runpath elements paths (see
   * http://www.scalatest.org/user_guide/using_the_runner) with values from Bazel's runfiles
   */
  private static void rlocateRunpathValue(String rulesWorkspace, List<String> runnerArgs)
      throws IOException {
    int runpathFlag = runnerArgs.indexOf("-R");
    if (runpathFlag >= 0) {
      String[] runpathElements = runnerArgs.get(runpathFlag + 1).split(File.pathSeparator);
      Runfiles runfiles = Runfiles.create();
      for (int i = 0; i < runpathElements.length; i++) {
        runpathElements[i] = runfiles.rlocation(rulesWorkspace + "/" + runpathElements[i]);
      }
      String runpath = String.join(File.separator, runpathElements);
      runnerArgs.set(runpathFlag + 1, runpath);
    }
  }
}
