package io.bazel.rulesscala.worker;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

@RunWith(JUnit4.class)
public class WorkerTest {

    private static void fill(ByteArrayOutputStream baos, int amount) {
	for (int i = 0; i < amount; i++) {
	    baos.write(0);
	}
    }

    @Test
    public void testWriteReadAndReset() throws Exception {
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
}
