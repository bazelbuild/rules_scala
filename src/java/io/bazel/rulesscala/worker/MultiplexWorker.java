package io.bazel.rulesscala.worker;

import com.google.devtools.build.lib.worker.WorkerProtocol;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintStream;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Multiplex JVM worker.
 *
 * <p>This supports regular workers as well as persisent workers.
 *
 * <p>Worker implementations should implement the `MultiplexWorker.Interface` interface and provide
 * a main method that calls `MultiplexWorker.workerMain`.
 */
public final class MultiplexWorker {

  private static ExecutorService executorService = Executors.newCachedThreadPool();

  public static interface Interface {
    public void work(String[] args, PrintStream out) throws Exception;
  }

  /**
   * The entry point for multiplex workers.
   *
   * <p>This should be the only thing called by a main method in a worker process.
   */
  public static void workerMain(String workerArgs[], Interface workerInterface) throws Exception {
    if (workerArgs.length > 0 && workerArgs[0].equals("--persistent_worker")) {
      persistentWorkerMain(workerInterface);
    } else {
      Worker.ephemeralWorkerMain(
          workerArgs,
          new Worker.Interface() {
            @Override
            public void work(String[] args) throws Exception {
              workerInterface.work(args, System.out);
            }
          });
    }
  }

  /** The main loop for persistent worker processes */
  private static void persistentWorkerMain(Interface workerInterface) {
    System.setSecurityManager(new PermissionSecurityManager());

    InputStream stdin = System.in;

    // We can't support stdin, so assign it to read from an empty buffer
    System.setIn(new ByteArrayInputStream(new byte[0]));

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

          if (request.getRequestId() == 0) {
            processWorkRequest(workerInterface, request);
          } else {
            executorService.submit(
                () -> {
                  processWorkRequest(workerInterface, request);
                });
          }

        } catch (IOException e) {
          // for now we swallow IOExceptions when
          // reading proto
        }
      }
    } finally {
      System.setIn(stdin);
    }
  }

  private static Object lock = new Object();

  private static void processWorkRequest(
      Interface workerInterface, WorkerProtocol.WorkRequest request) {
    int code = 0;
    ByteArrayOutputStream outStream = new ByteArrayOutputStream();
    PrintStream out = new PrintStream(outStream);

    try {
      workerInterface.work(stringListToArray(request.getArgumentsList()), out);
    } catch (ExitTrapped e) {
      code = e.code;
    } catch (Exception e) {
      out.println(e.getMessage());
      e.printStackTrace(out);
      code = 1;
    }

    try {
      out.flush();
      WorkerProtocol.WorkResponse response =
          WorkerProtocol.WorkResponse.newBuilder()
              .setExitCode(code)
              .setOutput(outStream.toString())
              .setRequestId(request.getRequestId())
              .build();

      synchronized (lock) {
        response.writeDelimitedTo(System.out);
      }
    } catch (IOException exception) {
      // for now we swallow IOExceptions when
      // writing proto
    } finally {
      try {
        outStream.close();
      } catch (IOException exception) {
      }
      System.gc();
    }
  }

  private static String[] stringListToArray(List<String> argList) {
    return argList.toArray(String[]::new);
  }
}
