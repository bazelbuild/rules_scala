package io.bazel.rulesscala.preconditions;

public class Preconditions {
  public static void require(boolean value) {
    if (!value) {
      throw new IllegalArgumentException();
    }
  }

  public static <T> T requireNotNull(T value) {
    if (value == null) {
      throw new NullPointerException();
    }

    return value;
  }
}
