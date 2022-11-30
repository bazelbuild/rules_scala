package io.bazel.rulesscala.scalac.reporter;

import static java.util.stream.Collectors.joining;

import io.bazel.rulesscala.scalac.compileoptions.CompileOptions;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.jar.JarFile;
import java.util.stream.Collectors;
import scala.reflect.internal.util.NoPosition$;
import scala.reflect.internal.util.Position;
import scala.tools.nsc.Settings;
import scala.tools.nsc.reporters.ConsoleReporter;
import scala.tools.nsc.reporters.Reporter;

public class DepsTrackingReporter extends ConsoleReporter {

  private final Set<String> classpathJars = new HashSet<>();
  private final Set<String> usedJars = new HashSet<>();

  private final Map<String, String> jarToTarget = new HashMap<>();
  private final Map<String, String> indirectJarToTarget = new HashMap<>();

  private final Set<String> ignoredTargets;
  private final Set<String> indirectTargets;
  private final Set<String> directTargets;

  // target -> used in ast
  private final Map<String, Boolean> usedTargets = new HashMap<>();
  private CompileOptions ops;
  private Reporter delegate;
  private Set<String> astUsedJars = new HashSet<>();

  private boolean astAssigned = false;

  public DepsTrackingReporter(Settings settings, CompileOptions ops, Reporter delegate) {
    super(settings);
    this.ops = ops;
    this.delegate = delegate;

    if (ops.directTargets.length == ops.directJars.length) {
      for (int i = 0; i < ops.directJars.length; i++) {
        try {
          jarToTarget.put(ops.directJars[i], ops.directTargets[i]);
        } catch (ArrayIndexOutOfBoundsException e) {
          throw new RuntimeException(
              "mismatched size: " + ops.directJars.length + " vs " + ops.directTargets.length);
        }
      }
    }

    if (ops.indirectTargets.length == ops.indirectJars.length) {
      for (int i = 0; i < ops.indirectJars.length; i++) {
        indirectJarToTarget.put(ops.indirectJars[i], ops.indirectTargets[i]);
      }
    }

    ignoredTargets = Arrays.stream(ops.unusedDepsIgnoredTargets).collect(Collectors.toSet());
    directTargets = Arrays.stream(ops.directTargets).collect(Collectors.toSet());
    indirectTargets = Arrays.stream(ops.indirectTargets).collect(Collectors.toSet());
  }

  @Override
  public void info0(Position pos, String msg, Severity severity, boolean force) {
    if (msg.contains("[")) {
      // filter -verbose related messages
      analyzeDeps(msg);
    } else {
      if (delegate != null) {
        delegate.info0(pos, msg, severity, force);
      } else {
        super.info0(pos, msg, severity, force);
      }
    }
  }

  private void analyzeDeps(String msg) {
    if (msg.startsWith("[search path for source files: ]")) {
      parseClasspathLine(msg);
    } else if (msg.startsWith("[loaded class file")) {
      parseLoadedJar(msg);
    }
  }

  private void parseClasspathLine(String msg) {
    // [search path for source files: ]
    // [search path for class files: bazel-out/k8-fastbuild/bin/external/io_bazel_rules_scala_mustache/io_bazel_rules_scala_mustache.stamp/compiler-0.8.18-stamped.jar:bazel-out/k8-fastbuild/bin/external/io_bazel_rules_scala_scopt/io_bazel_rules_scala_scopt.stamp/scopt_2.12-4.0.0-RC2-stamped.jar:bazel-out/k8-fastbuild/bin/external/io_bazel_rules_scala_scrooge_generator/io_bazel_rules_scala_scrooge_generator.stamp/scrooge-generator_2.12-21.2.0-stamped.jar:bazel-out/k8-fastbuild/bin/external/io_bazel_rules_scala_util_core/io_bazel_rules_scala_util_core.stamp/util-core_2.12-21.2.0-stamped.jar:bazel-out/k8-fastbuild/bin/external/io_bazel_rules_scala_util_logging/io_bazel_rules_scala_util_logging.stamp/util-logging_2.12-21.2.0-stamped.jar:bazel-out/k8-fastbuild/bin/external/io_bazel_rules_scala_scala_parser_combinators/io_bazel_rules_scala_scala_parser_combinators.stamp/scala-parser-combinators_2.12-1.1.2-stamped.jar:bazel-out/k8-fastbuild/bin/external/io_bazel_rules_scala_scala_library/io_bazel_rules_scala_scala_library.stamp/scala-library-2.12.14-stamped.jar:bazel-out/k8-fastbuild/bin/external/io_bazel_rules_scala_scala_reflect/io_bazel_rules_scala_scala_reflect.stamp/scala-reflect-2.12.14-stamped.jar]
    String[] entries = msg.split("\n")[1].replaceFirst("^\\[search path for class files: ", "")
        .replaceFirst("]$", "")
        .split(":");

    classpathJars.addAll(Arrays.asList(entries));
  }

  private void parseLoadedJar(String msg) {
    //[loaded class file bazel-out/k8-fastbuild/bin/external/io_bazel_rules_scala_scala_library/io_bazel_rules_scala_scala_library.stamp/scala-library-2.12.14-stamped.jar(scala/annotation/Annotation.class) in 2ms]
    String jar = msg.replaceFirst("^\\[loaded class file ", "").replaceFirst("\\(.*$", "");
    if (jar.endsWith(".jar")) {
      usedJars.add(jar);
    }
  }

  public void prepareReport() {

    if (Objects.equals(ops.strictDepsMode, "off")) {
      return;
    }

    StringBuilder report = new StringBuilder(
        "\nverbose log dep tracking report:\n" + ops.strictDepsMode + "\n"
            + ops.unusedDependencyCheckerMode + "\n");

    Reporter reporter = delegate != null ? delegate : this;

    List<String> openedJars = new ArrayList<>();
    Set<BuildozerCommand> buildozerUsedCommands = new HashSet<>();
    Set<BuildozerCommand> buildozerUnusedCommands = new HashSet<>();

    report.append("Jar usage report:\n");
    // used, but not direct
    for (String jar : usedJars) {
      String target = jarToTarget.get(jar);
      Boolean usedInAst = astUsedJars.contains(jar);
      String indirectTarget = indirectJarToTarget.get(jar);
      if (target != null) {
        if (target.startsWith("Unknown")) {
          target = jarLabel(jar);
          openedJars.add(target + " " + jar + " " + jarToTarget.get(jar));
        }
        report.append("  D: ").append(jar).append(" ").append(target).append("\n");
        usedTargets.put(target, usedInAst);
      } else if (indirectTarget != null) {
        if (indirectTarget.startsWith("Unknown")) {
          indirectTarget = jarLabel(jar);
          openedJars.add(indirectTarget + " " + jar + " " + indirectJarToTarget.get(jar));
        }
        report.append("  I: ").append(jar).append(" ").append(indirectTarget).append("\n");
        usedTargets.put(indirectTarget, usedInAst);
      } else {
        report.append("  Z: ").append(jar).append("\n");
      }
    }

    report.append("\nTarget usage report:\n");
    report.append("IG T: " + String.join(", ", ignoredTargets) + "\n");
    report.append("D T: " + String.join(", ", directTargets) + "\n");
    report.append("AST Assigned?: " + astAssigned + " r: " + String.join(", ", astUsedJars) + "\n");

    if (!ops.unusedDependencyCheckerMode.equals("off")) {
      for (String target : ops.directTargets) {
        if (!usedTargets.containsKey(target) && !ignoredTargets.contains(target)) {
          report.append("-").append(target).append("\n");
          buildozerUnusedCommands.add(
              new BuildozerCommand("buildozer 'remove deps " + target + "' " + ops.currentTarget,
                  usedTargets.getOrDefault(target, false)));
        }
      }
    }

    if (!ops.strictDepsMode.equals("off")) {
      for (String target : usedTargets.keySet()) {
        if (!directTargets.contains(target) && indirectTargets.contains(target)
            && !ignoredTargets.contains(target)) {
          report.append("+").append(target).append("\n");
          buildozerUsedCommands.add(
              new BuildozerCommand("buildozer 'add deps " + target + "' " + ops.currentTarget,
                  usedTargets.get(target)));
        }
      }
    }

    if (openedJars.size() > 0) {
      report.append("\nopened jars:\n");
    }
    for (String openedJar : openedJars) {
      report.append("  ").append(openedJar).append("\n");
    }

    reporter.warning(NoPosition$.MODULE$, report.toString());


    /* prints errors */

    if (buildozerUsedCommands.size() > 0) {

      for (BuildozerCommand command : buildozerUsedCommands) {
        if (command.isError()) {
          reporter.error(NoPosition$.MODULE$, "Fix missing direct deps:\n" + command + "\n");
        } else {
          reporter.warning(NoPosition$.MODULE$, "Fix missing direct deps:\n" + command + "\n");
        }
      }
    }

    if (buildozerUnusedCommands.size() > 0) {
      String unusedCommands = buildozerUnusedCommands.stream().map(BuildozerCommand::toString)
          .collect(
              joining("\n"));
      if (ops.unusedDependencyCheckerMode.equals("error")) {
        reporter.error(NoPosition$.MODULE$, "Fix unused direct deps:\n" + unusedCommands);
      } else {
        reporter.warning(NoPosition$.MODULE$, "Fix unused direct deps:\n" + unusedCommands);
      }
    }
  }

  private String jarLabel(String path) {
    try (JarFile jar = new JarFile(path)) {
      return jar.getManifest().getMainAttributes().getValue("Target-Label");
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  public void registerAstUsedJars(Set<String> jars) {
    astUsedJars = jars;
    astAssigned = true;
  }

  private static class BuildozerCommand {

    private final String command;
    private final boolean error;

    public BuildozerCommand(String command, boolean error) {
      this.command = command;
      this.error = error;
    }

    @Override
    public String toString() {
      return command;
    }

    public boolean isError() {
      return error;
    }
  }
}
