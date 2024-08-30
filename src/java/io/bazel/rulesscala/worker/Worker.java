package io.bazel.rulesscala.worker;

import com.google.devtools.build.lib.worker.WorkerProtocol;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.Permission;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * A base for JVM workers.
 *
 * <p>This supports regular workers as well as persisent workers. It does not (yet) support
 * multiplexed workers.
 *
 * <p>Worker implementations should implement the `Worker.Interface` interface and provide a main
 * method that calls `Worker.workerMain`.
 */
public final class Worker {

  public static interface Interface {
    public void work(String[] args) throws Exception;


    public abstract class WorkerException extends RuntimeException {
			public WorkerException(String message) {
				super(message);
			}
      public WorkerException(String message, Throwable cause) {
				super(message, cause);
			}
		}
  }

  /**
   * The entry point for all workers.
   *
   * <p>This should be the only thing called by a main method in a worker process.
   */
  public static void workerMain(String workerArgs[], Interface workerInterface) throws Exception {
    if (workerArgs.length > 0 && workerArgs[0].equals("--persistent_worker")) {
      persistentWorkerMain(workerInterface);
    } else {
      ephemeralWorkerMain(workerArgs, workerInterface);
    }
  }

  /** The main loop for persistent worker processes */
  private static void persistentWorkerMain(Interface workerInterface) {
    System.setSecurityManager(
        new SecurityManager() {
          @Override
          public void checkPermission(Permission permission) {
            Matcher matcher = exitPattern.matcher(permission.getName());
            if (matcher.find()) throw new ExitTrapped(Integer.parseInt(matcher.group(1)));
          }
        });

    InputStream stdin = System.in;
    PrintStream stdout = System.out;
    PrintStream stderr = System.err;
    ByteArrayOutputStream outStream = new SmartByteArrayOutputStream();
    PrintStream out = new PrintStream(outStream);

    // We can't support stdin, so assign it to read from an empty buffer
    System.setIn(new ByteArrayInputStream(new byte[0]));

    System.setOut(out);
    System.setErr(out);

    try {
      while (true) {
        try {
          WorkerProtocol.WorkRequest request = WorkerProtocol.WorkRequest.parseDelimitedFrom(stdin);

          // The request will be null if stdin is closed.  We're
          // not sure if this happens in TheRealWorld™ but it is
          // useful for testing (to shut down a persistent
          // worker process).
          if (request == null) {
            break;
          }

          int code = 0;

          try {
            String[] workerArgs = stringListToArray(request.getArgumentsList());
            String[] args = expandArgsIfArgsfile(workerArgs);
            workerInterface.work(args);
          } catch (ExitTrapped e) {
            code = e.code;
          } catch (Exception e) {
            System.err.println(e.getMessage());
            if (e instanceof Interface.WorkerException) {}
            else e.printStackTrace();
            code = 1;
          }

          WorkerProtocol.WorkResponse.newBuilder()
              .setExitCode(code)
              .setOutput(outStream.toString())
              .build()
              .writeDelimitedTo(stdout);

        } catch (IOException e) {
          // for now we swallow IOExceptions when
          // reading/writing proto
        } finally {
          out.flush();
          outStream.reset();
          System.gc();
        }
      }
    } finally {
      System.setIn(stdin);
      System.setOut(stdout);
      System.setErr(stderr);
    }
  }

  /** The single pass runner for ephemeral (non-persistent) worker processes */
  private static void ephemeralWorkerMain(String workerArgs[], Interface workerInterface)
      throws Exception {
    String[] args = expandArgsIfArgsfile(workerArgs);
    workerInterface.work(args);
  }

  private static String[] expandArgsIfArgsfile(String[] allArgs) throws IOException {
    if (allArgs.length == 1 && allArgs[0].startsWith("@")) {
        return stringListToArray(
                Files.readAllLines(
                  Paths.get(allArgs[0].substring(1)),
                  StandardCharsets.UTF_8)
                );
      
    } else {
      return allArgs;
    }
  }

  /**
   * A ByteArrayOutputStream that sometimes shrinks its internal buffer during calls to `reset`.
   *
   * <p>In contrast, a regular ByteArrayOutputStream will only ever grow its internal buffer.
   *
   * <p>For an example of subclassing a ByteArrayOutputStream, see Spring's
   * ResizableByteArrayOutputStream:
   * https://github.com/spring-projects/spring-framework/blob/master/spring-core/src/main/java/org/springframework/util/ResizableByteArrayOutputStream.java
   */
  static class SmartByteArrayOutputStream extends ByteArrayOutputStream {
    // ByteArrayOutputStream's defualt Size is 32, which is extremely small
    // to capture stdout from any worker process. We choose a larger default.
    private static final int DEFAULT_SIZE = 256;

    public SmartByteArrayOutputStream() {
      super(DEFAULT_SIZE);
    }

    public boolean isOversized() {
      return this.buf.length > DEFAULT_SIZE;
    }

    @Override
    public void reset() {
      super.reset();
      // reallocate our internal buffer if we've gone over our
      // desired idle size
      if (this.isOversized()) {
        this.buf = new byte[DEFAULT_SIZE];
      }
    }
  }

  static class ExitTrapped extends RuntimeException {
    final int code;

    ExitTrapped(int code) {
      super();
      this.code = code;
    }
  }

  private static Pattern exitPattern = Pattern.compile("exitVM\\.(-?\\d+)");

  private static String[] stringListToArray(List<String> argList) {
    int numArgs = argList.size();
    String[] args = new String[numArgs];
    for (int i = 0; i < numArgs; i++) {
      args[i] = argList.get(i);
    }
    return args;
  }
}
