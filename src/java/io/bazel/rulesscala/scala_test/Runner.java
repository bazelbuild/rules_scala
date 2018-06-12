package io.bazel.rulesscala.scala_test;

import java.util.Map;

/** This exists only as a proxy for scala tests's runner to provide access to env variables */
public class Runner {
  /**
   * This is the name of the env var set by bazel when a user provides a `--test_filter` test option
   */
  private static final String TESTBRIDGE_TEST_ONLY = "TESTBRIDGE_TEST_ONLY";

  public static void main(String[] args) {
    org.scalatest.tools.Runner.main(extendArgs(args, System.getenv()));
  }

  private static String[] extendArgs(String[] args, Map<String, String> env) {
    return extendFromEnvVar(args, env, TESTBRIDGE_TEST_ONLY, "-s");
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
