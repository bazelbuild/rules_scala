package io.bazel.rulesscala.scala_test;

import com.google.devtools.build.runfiles.Runfiles;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;

/** This exists only as a proxy for scala tests's runner to provide access to env variables */
public class Runner {
  /**
   * This is the name of the env var set by bazel when a user provides a `--test_filter` test option
   */
  private static final String TESTBRIDGE_TEST_ONLY = "TESTBRIDGE_TEST_ONLY";

  /**
   * This is the name of the system property used to pass Bazel's workspace name
   */
  private static final String RULES_SCALA_WS = "RULES_SCALA_WS";

  /**
   * This is the name of the system property used to pass a short path of the file, which includes
   * <code>org.scalatest.tools.Runner</code> arguments
   */
  private static final String RULES_SCALA_ARGS_FILE = "RULES_SCALA_ARGS_FILE";

  public static void main(String[] args) throws IOException {
    org.scalatest.tools.Runner.main(extendArgs(args, System.getenv()));
  }

  private static String[] extendArgs(String[] args, Map<String, String> env) throws IOException {
    args = extendFromSystemPropArgs(args);
    args = extendFromEnvVar(args, env, TESTBRIDGE_TEST_ONLY, "-s");
    return args;
  }

  private static String[] extendFromSystemPropArgs(String[] args) throws IOException {
    String rulesWorkspace = System.getProperty(RULES_SCALA_WS);
    if (rulesWorkspace == null || rulesWorkspace.trim().isEmpty())
      throw new IllegalArgumentException(RULES_SCALA_WS + " is null or empty.");

    String rulesArgsKey = System.getProperty(RULES_SCALA_ARGS_FILE);
    if (rulesArgsKey == null || rulesArgsKey.trim().isEmpty())
      throw new IllegalArgumentException(RULES_SCALA_ARGS_FILE + " is null or empty.");

    String rulesArgsPath = Runfiles.create().rlocation(rulesWorkspace + "/" + rulesArgsKey);
    if (rulesArgsPath == null)
      throw new IllegalArgumentException("rlocation value is null for key: " + rulesArgsKey);

    List<String> runnerArgs = Files.readAllLines(Paths.get(rulesArgsPath), Charset.forName("UTF-8"));

    int runpathFlag = runnerArgs.indexOf("-R");
    if (runpathFlag >= 0) {
      String runpathKey = runnerArgs.get(runpathFlag + 1);
      String runpath = Runfiles.create().rlocation(rulesWorkspace + "/" + runpathKey);
      runnerArgs.set(runpathFlag + 1, runpath);
    }

    String[] runnerArgsArray = runnerArgs.toArray(new String[runnerArgs.size()]);

    String[] result = new String[args.length + runnerArgsArray.length];
    System.arraycopy(args, 0, result, 0, args.length);
    System.arraycopy(runnerArgsArray, 0, result, args.length, runnerArgsArray.length);

    return result;
  }

  private static String[] extendFromEnvVar(
      String[] args, Map<String, String> env, String varName, String flagName) {
    String value = env.get(varName);
    if (value == null) {
      return args;
    }
    ;
    String[] flag = new String[] {flagName, value};
    String[] result = new String[args.length + flag.length];
    System.arraycopy(args, 0, result, 0, args.length);
    System.arraycopy(flag, 0, result, args.length, flag.length);

    return result;
  }
}
