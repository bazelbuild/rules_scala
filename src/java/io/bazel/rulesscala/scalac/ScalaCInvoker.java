// Copyright 2014 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package io.bazel.rulesscala.scalac;

import com.google.common.collect.ImmutableSet;
import com.google.devtools.build.lib.worker.WorkerProtocol.WorkRequest;
import com.google.devtools.build.lib.worker.WorkerProtocol.WorkResponse;
import io.bazel.rulesscala.jar.JarCreator;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.lang.reflect.Field;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.Files;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.JarOutputStream;
import java.util.List;
import java.util.Map.Entry;
import java.util.Map;
import java.util.TreeMap;
import scala.Console$;
import scala.tools.nsc.*;
import scala.tools.nsc.reporters.ConsoleReporter;
import static java.nio.charset.StandardCharsets.UTF_8;

/**
 * This is our entry point to producing a scala target
 * this can act as one of Bazel's persistant workers.
 */
public class ScalaCInvoker {
  // Mostly lifted from bazel
  private static void runPersistentWorker() throws IOException {
    PrintStream originalStdOut = System.out;
    PrintStream originalStdErr = System.err;

    while (true) {
      try {
        WorkRequest request = WorkRequest.parseDelimitedFrom(System.in);
        if (request == null) {
          break;
        }

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        int exitCode = 0;

        try (PrintStream ps = new PrintStream(baos)) {
          System.setOut(ps);
          System.setErr(ps);
          Console$.MODULE$.setErrDirect(ps);
          Console$.MODULE$.setOutDirect(ps);
          try {
            processRequest(request.getArgumentsList());
          } catch (Exception e) {
            e.printStackTrace();
            exitCode = 1;
          }
        } finally {
          System.setOut(originalStdOut);
          System.setErr(originalStdErr);
        }

        WorkResponse.newBuilder()
            .setOutput(baos.toString())
            .setExitCode(exitCode)
            .build()
            .writeDelimitedTo(System.out);
        System.out.flush();
      } finally {
        System.gc();
      }
    }
  }

  static private String[] extractSourceJars(CompileOptions opts, Path tmpParent) throws IOException {
    List<File> sourceFiles = new ArrayList<File>();

    for(String jarPath : opts.sourceJars) {
      if (jarPath.length() > 0){
        Path tmpPath = Files.createTempDirectory(tmpParent, "tmp");
        sourceFiles.addAll(extractJar(jarPath, tmpPath.toString()));
      }
    }
    String[] files = appendToString(opts.files, sourceFiles);
    if(files.length == 0) {
      throw new RuntimeException("Must have input files from either source jars or local files.");
    }
    return files;
  }

  private static List<File> extractJar(String jarPath,
      String outputFolder) throws IOException, FileNotFoundException {

    List<File> outputPaths = new ArrayList<File>();
    JarFile jar = new JarFile(jarPath);
    Enumeration e = jar.entries();
    while (e.hasMoreElements()) {
      JarEntry file = (JarEntry) e.nextElement();
      File f = new File(outputFolder + File.separator + file.getName());

      if (file.isDirectory()) { // if its a directory, create it
        f.mkdirs();
        continue;
      }

      File parent = f.getParentFile();
      parent.mkdirs();
      outputPaths.add(f);

      InputStream is = jar.getInputStream(file); // get the input stream
      FileOutputStream fos = new FileOutputStream(f);
      while (is.available() > 0) {  // write contents of 'is' to 'fos'
        fos.write(is.read());
      }
      fos.close();
      is.close();
    }
    return outputPaths;
  }

  static <T> String[] appendToString(String[] init, List<T> rest) {
    String[] tmp = new String[init.length + rest.size()];
    System.arraycopy(init, 0, tmp, 0, init.length);
    int baseIdx = init.length;
    for(T t : rest) {
      tmp[baseIdx] = t.toString();
      baseIdx += 1;
    }
    return tmp;
  }
  public static String[] merge(String[]... arrays) {
    int totalLength = 0;
    for(String[] arr:arrays){
      totalLength += arr.length;
    }

    String[] result = new String[totalLength];
    int offset = 0;
    for(String[] arr:arrays){
      System.arraycopy(arr, 0, result, offset, arr.length);
      offset += arr.length;
    }
    return result;
  }

  /**
   * This is the reporter field for scalac, which we want to access
   */
  private static Field reporterField;
  static {
    try {
      reporterField = Driver.class.getDeclaredField("reporter"); //NoSuchFieldException
      reporterField.setAccessible(true);
    }
    catch (Exception ex) {
      throw new RuntimeException("nope", ex);
    }
  }

  private static void processRequest(List<String> args) throws Exception {
    Path tmpPath = null;
    try {
      if (args.size() == 1 && args.get(0).startsWith("@")) {
        args = Files.readAllLines(Paths.get(args.get(0).substring(1)), UTF_8);
      }
      CompileOptions ops = new CompileOptions(args);

      Path outputPath = FileSystems.getDefault().getPath(ops.outputName);
      tmpPath = Files.createTempDirectory(outputPath.getParent(), "tmp");
      String[] constParams = {
        "-classpath",
        ops.classpath,
        "-d",
        tmpPath.toString()
        };

      String[] compilerArgs = merge(
        ops.scalaOpts,
        ops.pluginArgs,
        constParams,
        extractSourceJars(ops, outputPath.getParent()));

      MainClass comp = new MainClass();
      long start = System.currentTimeMillis();
      comp.process(compilerArgs);
      long stop = System.currentTimeMillis();
      if (ops.printCompileTime) {
        System.err.println("Compiler runtime: " + (stop - start) + "ms.");
      }

      ConsoleReporter reporter = (ConsoleReporter) reporterField.get(comp);

      if (reporter.hasErrors()) {
          reporter.printSummary();
          reporter.flush();
          throw new RuntimeException("Build failed");
      } else {
        /**
         * See if there are java sources to compile
         */
        if (ops.javaFiles.length > 0) {
          compileJavaSources(ops, tmpPath);
        }
        /**
         * Copy the resources
         */
        copyResources(ops.resourceFiles, tmpPath);
        /**
         * Now build the output jar
         */
        String[] jarCreatorArgs = {
          "-m",
          ops.manifestPath,
          outputPath.toString(),
          tmpPath.toString()
        };
        JarCreator.buildJar(jarCreatorArgs);

        /**
         * Now build the output ijar
         */
        if(ops.iJarEnabled) {
          Process iostat = new ProcessBuilder()
            .command(ops.ijarCmdPath, ops.outputName, ops.ijarOutput)
            .inheritIO()
            .start();
          int exitCode = iostat.waitFor();
          if(exitCode != 0) {
            throw new RuntimeException("ijar process failed!");
          }
        }
      }
    }
    finally {
      removeTmp(tmpPath);
    }
  }

  private static void compileJavaSources(CompileOptions ops, Path tmpPath) throws IOException, InterruptedException {
    StringBuilder cmd = new StringBuilder();
    cmd.append(ops.javacPath);
    if (ops.jvmFlags != "") cmd.append(ops.jvmFlags);
    if (ops.javacOpts != "") cmd.append(ops.javacOpts);

    StringBuilder files = new StringBuilder();
    int cnt = 0;
    for(String javaFile : ops.javaFiles) {
      if (cnt > 0) files.append(" ");
      files.append(javaFile);
      cnt += 1;
    }
    Process iostat = new ProcessBuilder()
      .command(cmd.toString(),
          "-classpath", ops.classpath + ":" + tmpPath.toString(),
          "-d", tmpPath.toString(),
          files.toString())
      .inheritIO()
      .start();
    int exitCode = iostat.waitFor();
    if(exitCode != 0) {
      throw new RuntimeException("javac process failed!");
    }
  }
  private static void removeTmp(Path tmp) throws IOException {
    if (tmp != null) {
      Files.walkFileTree(tmp, new SimpleFileVisitor<Path>() {
         @Override
         public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
             Files.delete(file);
             return FileVisitResult.CONTINUE;
         }

         @Override
         public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
             Files.delete(dir);
             return FileVisitResult.CONTINUE;
         }
      });
    }
  }
  private static void copyResources(Map<String, String> resources, Path dest) throws IOException {
    for(Entry<String, String> e : resources.entrySet()) {
      Path source = Paths.get(e.getKey());
      String dstr = e.getValue();
      if (dstr.charAt(0) == '/') dstr = dstr.substring(1);
      Path target = dest.resolve(dstr);
      File tfile = target.getParent().toFile();
      tfile.mkdirs();
      Files.copy(source, target);
    }
  }

  public static void main(String[] args) {
    try {
      if (ImmutableSet.copyOf(args).contains("--persistent_worker")) {
        runPersistentWorker();
      }
      else {
        processRequest(Arrays.asList(args));
      }
    }
    catch (Exception ex) {
      throw new RuntimeException("nope", ex);
    }
  }
}
