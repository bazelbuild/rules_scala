package io.bazel.rulesscala.worker;

import com.google.devtools.build.lib.worker.WorkerProtocol;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import static org.junit.Assert.assertEquals;

@RunWith(JUnit4.class)
public class WorkerTest {

  @Test
  public void testEphemeralWorkerSystemExit() throws Exception {

    // An ephemeral worker behaves like a regular main method,
    // so we expect the worker to system exit normally

    Worker.Interface worker =
        new Worker.Interface() {
          @Override
          public void work(String[] args) {
            System.exit(99);
          }
        };

    int code =
        assertThrows(Worker.ExitTrapped.class, () -> Worker.workerMain(new String[] {}, worker))
            .code;

    assert (code == 99);
  }

  @Test
  public void testPersistentWorkerSystemExit() throws Exception {
    // We're going to spin up a persistent worker and run a single
    // work request. We expect System.exit calls to impact the
    // worker request lifecycle without exiting the overall worker
    // process.

    try (PersistentWorkerHelper helper = new PersistentWorkerHelper(); ) {
      WorkerProtocol.WorkRequest.newBuilder().build().writeDelimitedTo(helper.requestOut);

      Worker.Interface worker =
          new Worker.Interface() {
            @Override
            public void work(String[] args) {
              // we should see this print statement
              System.out.println("before exit");
              System.exit(100);
              // we should not see this print statement
              System.out.println("after exit");
            }
          };

      helper.runWorker(worker);

      WorkerProtocol.WorkResponse response =
          WorkerProtocol.WorkResponse.parseDelimitedFrom(helper.responseIn);

      assert (response.getOutput().contains("before"));
      assert (response.getExitCode() == 100);
      assert (!response.getOutput().contains("after"));
    }
  }

  @Test
  public void testPersistentWorkerNoStdin() throws Exception {
    try (PersistentWorkerHelper helper = new PersistentWorkerHelper(); ) {
      WorkerProtocol.WorkRequest.newBuilder().build().writeDelimitedTo(helper.requestOut);

      final AtomicInteger result = new AtomicInteger();
      Worker.Interface worker =
          new Worker.Interface() {
            @Override
            public void work(String[] args) throws Exception {
              result.set(System.in.read());
            }
          };

      helper.runWorker(worker);
      assert (result.get() == -1);
    }
  }

  @Test
  public void testPersistentWorkerArgsfile() throws Exception {
    Path tmpFile = Files.createTempFile("testPersistentWorkerArgsfiles-args", ".txt");

    try (PersistentWorkerHelper helper = new PersistentWorkerHelper()) {
      Worker.Interface worker =
          new Worker.Interface() {
            @Override
            public void work(String[] args) {
              for (String arg : args) {
                System.out.println(arg);
              }
            }
          };

      String contents = "line 1\n--flag_1\nsome arg\n";

      Files.write(tmpFile, contents.getBytes(StandardCharsets.UTF_8));

      WorkerProtocol.WorkRequest.newBuilder()
          .addArguments("@" + tmpFile)
          .build()
          .writeDelimitedTo(helper.requestOut);

      helper.runWorker(worker);

      WorkerProtocol.WorkResponse response =
          WorkerProtocol.WorkResponse.parseDelimitedFrom(helper.responseIn);

      assertEquals(response.getExitCode(), 0);
      assertEquals(response.getOutput(), contents);
    } finally {
      Files.deleteIfExists(tmpFile);
    }
  }

  /** A helper to manage IO when testing a persistent worker. */
  private final class PersistentWorkerHelper implements AutoCloseable {

    public final PipedInputStream workerIn;
    public final PipedOutputStream requestOut;

    public final PipedOutputStream workerOut;
    public final PipedInputStream responseIn;

    private final InputStream stdin;
    private final PrintStream stdout;
    private final PrintStream stderr;

    public PersistentWorkerHelper() throws IOException {
      this.workerIn = new PipedInputStream();
      this.requestOut = new PipedOutputStream(workerIn);
      this.workerOut = new PipedOutputStream();
      this.responseIn = new PipedInputStream(workerOut);

      this.stdin = System.in;
      this.stdout = System.out;
      this.stderr = System.err;

      System.setIn(this.workerIn);
      System.setOut(new PrintStream(this.workerOut));
    }

    public void runWorker(Worker.Interface worker) throws Exception {
      // otherwise the worker will poll indefinitely
      this.requestOut.close();
      Worker.workerMain(new String[] {"--persistent_worker"}, worker);
    }

    public void close() {
      try {
        this.workerIn.close();
      } catch (IOException e) {
      }
      try {
        this.requestOut.close();
      } catch (IOException e) {
      }
      try {
        this.workerOut.close();
      } catch (IOException e) {
      }
      try {
        this.responseIn.close();
      } catch (IOException e) {
      }

      System.setIn(this.stdin);
      System.setOut(this.stdout);
      System.setErr(this.stderr);
    }
  }

  private static void fill(ByteArrayOutputStream baos, int amount) {
    for (int i = 0; i < amount; i++) {
      baos.write(0);
    }
  }

  @Test
  public void testBufferWriteReadAndReset() throws Exception {
    Worker.SmartByteArrayOutputStream baos = new Worker.SmartByteArrayOutputStream();
    PrintStream out = new PrintStream(baos);

    out.print("hello, world");
    assert (baos.toString("UTF-8").equals("hello, world"));
    assert (!baos.isOversized());

    fill(baos, 300);
    assert (baos.isOversized());
    baos.reset();

    out.print("goodbye, world");
    assert (baos.toString("UTF-8").equals("goodbye, world"));
    assert (!baos.isOversized());
  }

  @AfterClass
  public static void teardown() {
    // Persistent workers install a security manager. We need to
    // reset it here so that our own process can exit!
    System.setSecurityManager(null);
  }

  // Copied/modified from Bazel's MoreAsserts
  //
  // Note: this goes away soon-ish, as JUnit 4.13 was recently
  // released and includes assertThrows
  public static <T extends Throwable> T assertThrows(
      Class<T> expectedThrowable, ThrowingRunnable runnable) {
    try {
      runnable.run();
    } catch (Throwable actualThrown) {
      if (expectedThrowable.isInstance(actualThrown)) {
        @SuppressWarnings("unchecked")
        T retVal = (T) actualThrown;
        return retVal;
      } else {
        throw new AssertionError(
            String.format(
                "expected %s to be thrown, but %s was thrown",
                expectedThrowable.getSimpleName(), actualThrown.getClass().getSimpleName()),
            actualThrown);
      }
    }
    String mismatchMessage =
        String.format(
            "expected %s to be thrown, but nothing was thrown", expectedThrowable.getSimpleName());
    throw new AssertionError(mismatchMessage);
  }

  // see note on assertThrows
  public interface ThrowingRunnable {
    void run() throws Throwable;
  }
}
