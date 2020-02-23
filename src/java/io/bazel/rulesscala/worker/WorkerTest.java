package io.bazel.rulesscala.worker;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintStream;
import java.lang.SecurityManager;

import com.google.devtools.build.lib.worker.WorkerProtocol;

@RunWith(JUnit4.class)
public class WorkerTest {

    @Test
    public void testEphemeralWorkerSystemExit() throws Exception {

	// An ephemeral worker behaves like a regular main method,
	// so we expect the worker to system exit normally

	Worker.Interface worker = new Worker.Interface() {
            @Override
	    public void work(String[] args) {
		System.exit(99);
	    }
	};

	int code = assertThrows(Worker.ExitTrapped.class, () ->
	    Worker.workerMain(new String[]{}, worker)).code;

	assert(code == 99);
    }

    @Test
    public void testPersistentWorkerSystemExit() throws Exception {

	// We're going to spin up a persistent worker and run a single
	// work request. We expect System.exit calls to impact the
	// worker request lifecycle without exiting the overall worker
	// process.

	Worker.Interface worker = new Worker.Interface() {
            @Override
	    public void work(String[] args) {
		// we should see this print statement
		System.out.println("before exit");
		System.exit(100);
		// we should not see this print statement
		System.out.println("after exit");
	    }
	};

	try (
	    PipedInputStream workerIn = new PipedInputStream();
	    PipedOutputStream outToWorkerIn = new PipedOutputStream(workerIn);

	    PipedOutputStream workerOut = new PipedOutputStream();
	    PipedInputStream inFromWorkerOut = new PipedInputStream(workerOut);
	) {

	    InputStream stdin = System.in;
	    PrintStream stdout = System.out;
	    PrintStream stderr = System.err;

	    System.setIn(workerIn);
	    System.setOut(new PrintStream(workerOut));

	    WorkerProtocol.WorkRequest.newBuilder()
	        .build()
		.writeDelimitedTo(outToWorkerIn);

	    // otherwise the worker will poll indefinitely
	    outToWorkerIn.close();

	    Worker.workerMain(new String[]{"--persistent_worker"}, worker);

	    System.setIn(stdin);
	    System.setOut(stdout);
	    System.setErr(stderr);

	    WorkerProtocol.WorkResponse response =
		WorkerProtocol.WorkResponse.parseDelimitedFrom(inFromWorkerOut);

	    assert(response.getOutput().contains("before"));
	    assert(response.getExitCode() == 100);
	    assert(!response.getOutput().contains("after"));
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
	assert(baos.toString("UTF-8").equals("hello, world"));
	assert(!baos.isOversized());

	fill(baos, 300);
	assert(baos.isOversized());
	baos.reset();

	out.print("goodbye, world");
	assert(baos.toString("UTF-8").equals("goodbye, world"));
	assert(!baos.isOversized());
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
	Class<T> expectedThrowable,
	ThrowingRunnable runnable)
    {
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
			expectedThrowable.getSimpleName(),
		        actualThrown.getClass().getSimpleName()),
		    actualThrown);
	    }
	}
	String mismatchMessage = String.format(
	   "expected %s to be thrown, but nothing was thrown",
	   expectedThrowable.getSimpleName());
	throw new AssertionError(mismatchMessage);
    }

    // see note on assertThrows
    public interface ThrowingRunnable {
	void run() throws Throwable;
    }
}
