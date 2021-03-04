package io.bazel.rulesscala.scalac;

import io.bazel.rulesscala.scalac.CompileOptions.ArgMap;
import org.junit.Test;
import org.junit.function.ThrowingRunnable;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import static org.junit.Assert.*;

@RunWith(JUnit4.class)
public class CompileOptionsTest {

    @Test
    public void parse_empty_lines() {
        ArgMap args = new ArgMap(new String[]{});

        assertTrue(args.isEmpty());
    }

    @Test
    public void parse_flag_without_values() {
        ArgMap args = new ArgMap(new String[]{"--flag"});

        assertArrayEquals(args.get("flag"), new String[]{});
        assertEquals(args.size(), 1);
    }

    @Test
    public void parse_arg_with_single_value() {
        ArgMap args = new ArgMap(new String[]{"--arg", "value"});

        assertArrayEquals(args.get("arg"), new String[]{"value"});
        assertEquals(args.size(), 1);
    }

    @Test
    public void parse_arg_with_multiple_values() {
        ArgMap args = new ArgMap(new String[]{"--args", "value-1", "value-2", "value-3"});

        assertArrayEquals(args.get("args"), new String[]{"value-1", "value-2", "value-3"});
        assertEquals(args.size(), 1);
    }

    @Test
    public void extract_values() {
        ArgMap args = new ArgMap(new String[]{
                "--flag",
                "--arg",
                "value",
                "--args",
                "value-1",
                "value-2",
                "value-3"
        });

        assertArrayEquals(args.getOrEmpty("arg"), new String[]{"value"});
        assertArrayEquals(args.getOrEmpty("args"), new String[]{"value-1", "value-2", "value-3"});
        assertArrayEquals(args.getOrEmpty("flag"), new String[]{});
        assertArrayEquals(args.getOrEmpty("unknown"), new String[]{});

        assertEquals(args.getSingleOrError("arg"), "value");
        assertFails(() -> args.getSingleOrError("unknown"), "Missing required arg unknown");
        assertFails(() -> args.getSingleOrError("flag"), "flag expected to contain single value but got []");
        assertFails(
                () -> args.getSingleOrError("args"),
                "args expected to contain single value but got [value-1, value-2, value-3]"
        );
    }

    private static void assertFails(ThrowingRunnable action, String message) {
        Exception exception = assertThrows(RuntimeException.class, action);
        assertEquals(exception.getMessage(), message);
    }
}
