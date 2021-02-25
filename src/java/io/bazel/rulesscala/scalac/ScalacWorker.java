package io.bazel.rulesscala.scalac;

import io.bazel.rulesscala.io_utils.StreamCopy;
import io.bazel.rulesscala.jar.JarCreator;
import io.bazel.rulesscala.worker.Worker;
import scala.tools.nsc.reporters.ConsoleReporter;

import java.io.*;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.List;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import static java.io.File.pathSeparator;

class ScalacWorker implements Worker.Interface {

  private static final boolean isWindows = System.getProperty("os.name").toLowerCase()
      .contains("windows");

  public static void main(String[] args) throws Exception {
    Worker.workerMain(args, new ScalacWorker());
  }

  @Override
  public void work(String[] args) throws Exception {
    Path tmpPath = null;
    try {
      CompileOptions ops = new CompileOptions(args);

      Path outputPath = FileSystems.getDefault().getPath(ops.outputName);
      tmpPath = Files.createTempDirectory(outputPath.getParent(), "tmp");

      List<File> jarFiles = extractSourceJars(ops, outputPath.getParent());
      List<File> scalaJarFiles = filterFilesByExtension(jarFiles, ".scala");
      List<File> javaJarFiles = filterFilesByExtension(jarFiles, ".java");

      if (!ops.expectJavaOutput && ops.javaFiles.length != 0) {
        throw new RuntimeException("Cannot have java source files when no expected java output");
      }

      if (!ops.expectJavaOutput && !javaJarFiles.isEmpty()) {
        throw new RuntimeException(
            "Found java files in source jars but expect Java output is set to false");
      }

      String[] scalaSources = collectSrcJarSources(ops.files, scalaJarFiles, javaJarFiles);

      String[] javaSources = appendToString(ops.javaFiles, javaJarFiles);
      if (scalaSources.length == 0 && javaSources.length == 0) {
        throw new RuntimeException("Must have input files from either source jars or local files.");
      }

      /**
       * Compile scala sources if available (if there are none, we will simply compile java
       * sources).
       */
      if (scalaSources.length > 0) {
        compileScalaSources(ops, scalaSources, tmpPath);
      }

      /** Copy the resources */
      copyResources(ops.resourceSources, ops.resourceTargets, tmpPath);

      /** Extract and copy resources from resource jars */
      copyResourceJars(ops.resourceJars, tmpPath);

      /** Copy classpath resources to root of jar */
      copyClasspathResourcesToRoot(ops.classpathResourceFiles, tmpPath);

      /** Now build the output jar */
      String[] jarCreatorArgs = {
          "-m", ops.manifestPath,
          "-t", ops.currentTarget,
          outputPath.toString(),
          tmpPath.toString()
      };
      JarCreator.main(jarCreatorArgs);
    } finally {
      removeTmp(tmpPath);
    }
  }

  private static String[] collectSrcJarSources(
      String[] files, List<File> scalaJarFiles, List<File> javaJarFiles) {
    String[] scalaSources = appendToString(files, scalaJarFiles);
    return appendToString(scalaSources, javaJarFiles);
  }

  private static List<File> filterFilesByExtension(List<File> files, String extension) {
    List<File> filtered = new ArrayList<File>();
    for (File f : files) {
      if (f.toString().endsWith(extension)) {
        filtered.add(f);
      }
    }
    return filtered;
  }

  private static final String[] sourceExtensions = {".scala", ".java"};

  private static List<File> extractSourceJars(CompileOptions opts, Path tmpParent)
      throws IOException {
    List<File> sourceFiles = new ArrayList<File>();

    for (String jarPath : opts.sourceJars) {
      if (jarPath.length() > 0) {
        Path tmpPath = Files.createTempDirectory(tmpParent, "tmp");
        sourceFiles.addAll(extractJar(jarPath, tmpPath.toString(), sourceExtensions));
      }
    }

    return sourceFiles;
  }

  private static List<File> extractJar(String jarPath, String outputFolder, String[] extensions)
      throws IOException {

    List<File> outputPaths = new ArrayList<>();
    JarFile jar = new JarFile(jarPath);
    Enumeration<JarEntry> e = jar.entries();
    while (e.hasMoreElements()) {
      JarEntry file = e.nextElement();
      String thisFileName = file.getName();
      // we don't bother to extract non-scala/java sources (skip manifest)
      if (extensions != null && !matchesFileExtensions(thisFileName, extensions)) {
        continue;
      }
      File f = new File(outputFolder + File.separator + file.getName());

      if (file.isDirectory()) { // if it's a directory, create it
        f.mkdirs();
        continue;
      }

      File parent = f.getParentFile();
      parent.mkdirs();
      outputPaths.add(f);

      try (
          InputStream is = jar.getInputStream(file);
          OutputStream fos = new FileOutputStream(f)
      ) {
        StreamCopy.copy(is, fos);
      }
    }
    return outputPaths;
  }

  private static boolean matchesFileExtensions(String fileName, String[] extensions) {
    for (String e : extensions) {
      if (fileName.endsWith(e)) {
        return true;
      }
    }
    return false;
  }

  private static String[] encodeBazelTargets(String[] targets) {
    return Arrays.stream(targets).map(ScalacWorker::encodeBazelTarget).toArray(String[]::new);
  }

  private static String encodeBazelTarget(String target) {
    return target.replace(":", ";");
  }

  private static boolean isModeEnabled(String mode) {
    return !"off".equals(mode);
  }

  public static String[] buildPluginArgs(String[] pluginElements) {
    int numPlugins = 0;
    for (int i = 0; i < pluginElements.length; i++) {
      if (pluginElements[i].length() > 0) {
        numPlugins += 1;
      }
    }

    String[] result = new String[numPlugins];
    int idx = 0;
    for (int i = 0; i < pluginElements.length; i++) {
      if (pluginElements[i].length() > 0) {
        result[idx] = "-Xplugin:" + pluginElements[i];
        idx += 1;
      }
    }
    return result;
  }

  private static String[] getPluginParamsFrom(CompileOptions ops) {
    List<String> pluginParams = new ArrayList<>(0);

    if (isModeEnabled(ops.strictDepsMode) || isModeEnabled(ops.unusedDependencyCheckerMode)) {
      String currentTarget = encodeBazelTarget(ops.currentTarget);

      String[] dependencyAnalyzerParams = {
          "-P:dependency-analyzer:strict-deps-mode:" + ops.strictDepsMode,
          "-P:dependency-analyzer:unused-deps-mode:" + ops.unusedDependencyCheckerMode,
          "-P:dependency-analyzer:current-target:" + currentTarget,
          "-P:dependency-analyzer:dependency-tracking-method:" + ops.dependencyTrackingMethod,
      };

      pluginParams.addAll(Arrays.asList(dependencyAnalyzerParams));

      if (ops.directJars.length > 0) {
        pluginParams.add("-P:dependency-analyzer:direct-jars:" + String.join(":", ops.directJars));
      }
      if (ops.directTargets.length > 0) {
        String[] directTargets = encodeBazelTargets(ops.directTargets);
        pluginParams
            .add("-P:dependency-analyzer:direct-targets:" + String.join(":", directTargets));
      }
      if (ops.indirectJars.length > 0) {
        pluginParams
            .add("-P:dependency-analyzer:indirect-jars:" + String.join(":", ops.indirectJars));
      }
      if (ops.indirectTargets.length > 0) {
        String[] indirectTargets = encodeBazelTargets(ops.indirectTargets);
        pluginParams
            .add("-P:dependency-analyzer:indirect-targets:" + String.join(":", indirectTargets));
      }
      if (ops.unusedDepsIgnoredTargets.length > 0) {
        String[] ignoredTargets = encodeBazelTargets(ops.unusedDepsIgnoredTargets);
        pluginParams
            .add("-P:dependency-analyzer:unused-deps-ignored-targets:" + String
                .join(":", ignoredTargets));
      }
    }

    return pluginParams.toArray(new String[pluginParams.size()]);
  }

  private static void compileScalaSources(CompileOptions ops, String[] scalaSources, Path tmpPath)
      throws IllegalAccessException, IOException {

    String[] pluginArgs = buildPluginArgs(ops.plugins);
    String[] pluginParams = getPluginParamsFrom(ops);

    String[] constParams = {"-classpath", String.join(pathSeparator, ops.classpath), "-d", tmpPath.toString()};

    String[] compilerArgs =
        merge(ops.scalaOpts, pluginArgs, constParams, pluginParams, scalaSources);

    ReportableMainClass comp = new ReportableMainClass(ops);

    long start = System.currentTimeMillis();
    try {
      comp.process(compilerArgs);
    } catch (Throwable ex) {
      if (ex.toString().contains("scala.reflect.internal.Types$TypeError")) {
        throw new RuntimeException("Build failure with type error", ex);
      } else {
        throw ex;
      }
    }
    long stop = System.currentTimeMillis();
    if (ops.printCompileTime) {
      System.err.println("Compiler runtime: " + (stop - start) + "ms.");
    }

    try {
      Files.write(
          Paths.get(ops.statsfile), Arrays.asList("build_time=" + Long.toString(stop - start)));
    } catch (IOException ex) {
      throw new RuntimeException("Unable to write statsfile to " + ops.statsfile, ex);
    }

    ConsoleReporter reporter = (ConsoleReporter) comp.getReporter();
    if (reporter instanceof ProtoReporter) {
      ProtoReporter protoReporter = (ProtoReporter) reporter;
      protoReporter.writeTo(Paths.get(ops.diagnosticsFile));
    }

    if (reporter.hasErrors()) {
      reporter.flush();
      throw new RuntimeException("Build failed");
    }
  }

  private static void removeTmp(Path tmp) throws IOException {
    if (tmp != null) {
      Files.walkFileTree(
          tmp,
          new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)
                throws IOException {
              if (isWindows) {
                file.toFile().setWritable(true);
              }
              Files.delete(file);
              return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult postVisitDirectory(Path dir, IOException exc)
                throws IOException {
              Files.delete(dir);
              return FileVisitResult.CONTINUE;
            }
          });
    }
  }

  private static void copyResources(String[] sources, String[] targets, Path dest) throws IOException {
    if (sources.length != targets.length)
      throw new RuntimeException(String.format(
              "mismatch in resources: sources: %s targets: %s",
              Arrays.toString(sources), Arrays.toString(targets))
      );

    for (int i = 0; i < sources.length; i++) {
      Path source = Paths.get(sources[i]);
      Path target = dest.resolve(targets[i]);
      target.getParent().toFile().mkdirs();
      Files.copy(source, target);
    }
  }

  private static void copyClasspathResourcesToRoot(String[] classpathResourceFiles, Path dest)
      throws IOException {
    for (String s : classpathResourceFiles) {
      Path source = Paths.get(s);
      Path target = dest.resolve(source.getFileName());

      if (Files.exists(target)) {
        System.err.println(
            "Classpath resource file "
                + source.getFileName()
                + " has a namespace conflict with another file: "
                + target.getFileName());
      } else {
        Files.copy(source, target);
      }
    }
  }

  private static void copyResourceJars(String[] resourceJars, Path dest) throws IOException {
    for (String jarPath : resourceJars) {
      extractJar(jarPath, dest.toString(), null);
    }
  }

  private static <T> String[] appendToString(String[] init, List<T> rest) {
    String[] tmp = new String[init.length + rest.size()];
    System.arraycopy(init, 0, tmp, 0, init.length);
    int baseIdx = init.length;
    for (T t : rest) {
      tmp[baseIdx] = t.toString();
      baseIdx += 1;
    }
    return tmp;
  }

  private static String[] merge(String[]... arrays) {
    int totalLength = 0;
    for (String[] arr : arrays) {
      totalLength += arr.length;
    }

    String[] result = new String[totalLength];
    int offset = 0;
    for (String[] arr : arrays) {
      System.arraycopy(arr, 0, result, offset, arr.length);
      offset += arr.length;
    }
    return result;
  }
}
