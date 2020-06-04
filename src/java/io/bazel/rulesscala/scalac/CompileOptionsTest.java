package io.bazel.rulesscala.scalac;

import io.bazel.rulesscala.scalac.CompileOptions;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertEquals;

@RunWith(JUnit4.class)
public class CompileOptionsTest {

    @Test
    public void testEphemeralWorkerSystemExit() throws Exception {
        Map<String, String> argMap = new HashMap();
        argMap.put("ScalacOpts", "-Ystatistics:typer,parser:::-Xlint");
        String[] scalacOpts = CompileOptions.getTripleColonList(argMap, "ScalacOpts");
        assertEquals(new String[]{"-Ystatistics:typer,parser", "-Xlint"}, scalacOpts);
    }

}
