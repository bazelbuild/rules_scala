package io.bazel.rulesscala.worker;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.lang.SecurityManager;
import java.security.Permission;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.nio.charset.StandardCharsets;

import com.google.devtools.build.lib.worker.WorkerProtocol;

public final class Worker {

    public static interface Interface {
	public void work(String[] args) throws Exception;
    }

    public static void workerMain(String workerArgs[], Interface workerInterface) throws Exception {
	if (workerArgs.length > 0 && workerArgs[0].equals("--persistent_worker")) {

	    System.setSecurityManager(new SecurityManager() {
		    @Override
		    public void checkPermission(Permission permission) {
			Matcher matcher = exitPattern.matcher(permission.getName());
			if (matcher.find())
			    throw new ExitTrapped(Integer.parseInt(matcher.group(1)));
		    }
		});

	    InputStream stdin = System.in;
	    PrintStream stdout = System.out;
	    PrintStream stderr = System.err;
	    ByteArrayOutputStream outStream = new ByteArrayOutputStream();
	    PrintStream out = new PrintStream(outStream);

	    System.setIn(new ByteArrayInputStream(new byte[0]));
	    System.setOut(out);
	    System.setErr(out);

	    try {
		while (true) {
		    WorkerProtocol.WorkRequest request =
			WorkerProtocol.WorkRequest.parseDelimitedFrom(stdin);

		    int code = 0;

		    try {
			workerInterface.work(stringListToArray(request.getArgumentsList()));
		    } catch (ExitTrapped e) {
			code = e.code;
		    } catch (Exception e) {
			System.err.println(e.getMessage());
			e.printStackTrace();
			code = 1;
		    }

		    WorkerProtocol.WorkResponse.newBuilder()
			.setOutput(outStream.toString())
			.setExitCode(code)
			.build()
			.writeDelimitedTo(stdout);

		    out.flush();
		    outStream.reset();
		}
	    } catch (IOException e) {
	    } finally {
		System.setIn(stdin);
		System.setOut(stdout);
		System.setErr(stderr);
	    }
	} else {
	    String[] args;
	    if (workerArgs.length == 1 && workerArgs[0].startsWith("@")) {
		args = stringListToArray(Files.readAllLines(Paths.get(workerArgs[0].substring(1)), StandardCharsets.UTF_8));
	    } else {
		args = workerArgs;
	    }
	    workerInterface.work(args);
	}
    }

    private static class ExitTrapped extends RuntimeException {
	final int code;
	ExitTrapped(int code) {
	    super();
	    this.code = code;
	}
    }

    private static Pattern exitPattern =
	Pattern.compile("exitVM\\.(-?\\d+)");

    private static String[] stringListToArray(List<String> argList) {
	int numArgs = argList.size();
	String[] args = new String[numArgs];
	for (int i = 0; i < numArgs; i++) {
	    args[i] = argList.get(i);
	}
	return args;
    }
}
