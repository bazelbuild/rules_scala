package io.bazel.rulesscala.scalac.compileoptions;

import static org.junit.Assert.*;

import org.junit.Test;
import org.junit.function.ThrowingRunnable;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class CompileOptionsTest {

  @Test
  public void extractValuesFromParsedArgsFile() {
    CompileOptions.Args args =
        new CompileOptions.Args(
            new String[] {"--flag", "--arg", "value", "--args", "value-1", "value-2", "value-3"});

    assertArrayEquals(args.getOrEmpty("arg"), new String[] {"value"});
    assertArrayEquals(args.getOrEmpty("args"), new String[] {"value-1", "value-2", "value-3"});
    assertArrayEquals(args.getOrEmpty("flag"), new String[] {});
    assertArrayEquals(args.getOrEmpty("unknown"), new String[] {});

    assertEquals(args.getSingleOrError("arg"), "value");
    assertFails(() -> args.getSingleOrError("unknown"), "Missing required arg unknown");
    assertFails(
        () -> args.getSingleOrError("flag"), "flag expected to contain single value but got []");
    assertFails(
        () -> args.getSingleOrError("args"),
        "args expected to contain single value but got [value-1, value-2, value-3]");
  }

  private static void assertFails(ThrowingRunnable action, String message) {
    Exception exception = assertThrows(RuntimeException.class, action);
    assertEquals(exception.getMessage(), message);
  }
}
