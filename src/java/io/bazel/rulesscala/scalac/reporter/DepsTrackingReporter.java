package io.bazel.rulesscala.scalac.reporter;

import io.bazel.rulesscala.deps.proto.ScalaDeps;
import io.bazel.rulesscala.deps.proto.ScalaDeps.Dependency.Kind;
import io.bazel.rulesscala.scalac.compileoptions.CompileOptions;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
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

  private static final String HJAR_JAR_SUFFIX = "-hjar.jar";
  private static final String IJAR_JAR_SUFFIX = "-ijar.jar";
  private final Set<String> usedJars = new HashSet<>();

  private final Map<String, String> jarToTarget = new HashMap<>();
  private final Map<String, String> indirectJarToTarget = new HashMap<>();

  private final Set<String> ignoredTargets;
  private final Set<String> indirectTargets;
  private final Set<String> directTargets;

  private CompileOptions ops;
  public final Reporter delegateReporter;
  private Set<String> astUsedJars = new HashSet<>();

  public DepsTrackingReporter(Settings settings, CompileOptions ops, Reporter delegate) {
    super(settings);
    this.ops = ops;
    this.delegateReporter = delegate;

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

  private boolean isDependecyTrackingOn() {
    return Objects.equals(ops.dependencyTrackingMethod, "ast-plus")
        && (!"off".equals(ops.strictDepsMode) || !"off".equals(ops.unusedDependencyCheckerMode));
  }

  @Override
  public void info0(Position pos, String msg, Severity severity, boolean force) {
    if (msg.startsWith("DT:")) {
      if (isDependecyTrackingOn()) {
        parseOpenedJar(msg);
      }
    } else {
      if (delegateReporter != null) {
        delegateReporter.info0(pos, msg, severity, force);
      } else {
        super.info0(pos, msg, severity, force);
      }
    }
  }

  private void parseOpenedJar(String msg) {
    usedJars.add(msg.split(":")[1]);
  }

  public void prepareReport() throws IOException {
    Map<String, Dep> usedTargets = new HashMap<>();

    for (String jar : usedJars) {
      String target = jarToTarget.get(jar);
      boolean isDirect = target != null;

      if (target == null) {
        target = indirectJarToTarget.get(jar);
      }

      if (target.startsWith("Unknown")) {
        target = jarLabel(jar);
      }

      if (target == null) {
        // probably a bug if we get here
        continue;
      }

      Dep dep = new Dep(
          jar,
          target,
          astUsedJars.contains(jar),
          isDirect,
          ignoredTargets.contains(target)
      );

      usedTargets.put(target, dep);
    }

    Set<Dep> unusedDeps = new HashSet<>();

    for (int i = 0; i < ops.directTargets.length; i++) {
      String directTarget = ops.directTargets[i];
      if (usedTargets.containsKey(directTarget)) {
        continue;
      }

      unusedDeps.add(
          new Dep(
              ops.directJars[i],
              directTarget,
              false,
              true,
              ignoredTargets.contains(directTarget)
          )
      );
    }

    ScalaDeps.Dependencies.Builder builder = ScalaDeps.Dependencies.newBuilder();
    builder.setRuleLabel(ops.currentTarget);

    for (Dep dep : usedTargets.values()) {
      ScalaDeps.Dependency.Builder dependecyBuilder = ScalaDeps.Dependency.newBuilder();

      ScalaDeps.Dependency.Kind kind = dep.usedInAst ? Kind.EXPLICIT : Kind.IMPLICIT;

      dependecyBuilder.setKind(kind);
      dependecyBuilder.setLabel(dep.target);
      dependecyBuilder.setIjarPath(dep.jar);
      dependecyBuilder.setPath(guessFullJarPath(dep.jar));
      dependecyBuilder.setIgnored(dep.ignored);

      builder.addDependency(dependecyBuilder.build());
    }

    for (Dep dep : unusedDeps) {
      ScalaDeps.Dependency.Builder dependecyBuilder = ScalaDeps.Dependency.newBuilder();

      ScalaDeps.Dependency.Kind kind = Kind.UNUSED;

      dependecyBuilder.setKind(kind);
      dependecyBuilder.setLabel(dep.target);
      dependecyBuilder.setIjarPath(dep.jar);
      dependecyBuilder.setPath(guessFullJarPath(dep.jar));
      dependecyBuilder.setIgnored(dep.ignored);

      builder.addDependency(dependecyBuilder.build());
    }

    try (OutputStream outputStream = new BufferedOutputStream(
        Files.newOutputStream(Paths.get(ops.scalaDepsFile)))) {
      outputStream.write(builder.build().toByteArray());
    }

    Reporter reporter = this.delegateReporter != null ? this.delegateReporter : this;

    if (ops.dependencyTrackingMethod.equals("ast-plus")) {

      if (!ops.strictDepsMode.equals("off")) {
        StringBuilder strictDepsReport = new StringBuilder("Missing strict dependencies:\n");
        StringBuilder compilerDepsReport = new StringBuilder("Missing compiler dependencies:\n");
        int strictDepsCount = 0;
        int compilerDepsCount = 0;
        for (Dep dep : usedTargets.values()) {
          String depReport = reportDep(dep, true);
          if (dep.ignored) {
            continue;
          }

          if (directTargets.contains(dep.target)) {
            continue;
          }

          if (dep.usedInAst) {
            strictDepsCount++;
            strictDepsReport.append(depReport);
          } else {
            compilerDepsCount++;
            compilerDepsReport.append(depReport);
          }
        }

        if (strictDepsCount > 0) {
          if (ops.strictDepsMode.equals("warn")) {
            reporter.warning(NoPosition$.MODULE$, strictDepsReport.toString());
          } else {
            reporter.error(NoPosition$.MODULE$, strictDepsReport.toString());
          }
        }

        if (!ops.compilerDepsMode.equals("off") && compilerDepsCount > 0) {
          if (ops.compilerDepsMode.equals("warn")) {
            reporter.warning(NoPosition$.MODULE$, compilerDepsReport.toString());
          } else {
            reporter.error(NoPosition$.MODULE$, compilerDepsReport.toString());
          }
        }
      }

      if (!ops.unusedDependencyCheckerMode.equals("off")) {
        StringBuilder unusedDepsReport = new StringBuilder("Unused dependencies:\n");
        int count = 0;
        for (Dep dep : unusedDeps) {
          if (dep.ignored) {
            continue;
          }
          count++;
          unusedDepsReport.append(reportDep(dep, false));
        }
        if (count > 0) {
          if (ops.unusedDependencyCheckerMode.equals("warn")) {
            reporter.warning(NoPosition$.MODULE$, unusedDepsReport.toString());
          } else if (ops.unusedDependencyCheckerMode.equals("error")) {
            reporter.error(NoPosition$.MODULE$, unusedDepsReport.toString());
          }
        }
      }
    }

  }

  private String reportDep(Dep dep, boolean add) {
    String message = dep.target + "\n";
    String command = add ? "add" : "remove";
    String buildozer = "buildozer '" + command + " deps " + dep.target + "' " + ops.currentTarget;
    return message + buildozer + "\n";
  }

  private String guessFullJarPath(String jar) {
    if (jar.endsWith(IJAR_JAR_SUFFIX)) {
      return stripIjarSuffix(jar, IJAR_JAR_SUFFIX);
    } else if (jar.endsWith(HJAR_JAR_SUFFIX)) {
      return stripIjarSuffix(jar, HJAR_JAR_SUFFIX);
    } else {
      return jar;
    }
  }

  private static String stripIjarSuffix(String jar, String suffix) {
    return jar.substring(0, jar.length() - suffix.length()) + ".jar";
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
  }

  public void writeDiagnostics(String diagnosticsFile) throws IOException {
    if (delegateReporter == null) {
      return;
    }

    ProtoReporter protoReporter = (ProtoReporter) delegateReporter;
    protoReporter.writeTo(Paths.get(diagnosticsFile));
  }

  private static class Dep {

    public final String jar;

    public final String target;
    public final boolean usedInAst;
    public final boolean direct;
    public final boolean ignored;

    public Dep(String jar, String target, boolean usedInAst, boolean direct, boolean ignored) {
      this.jar = jar;
      this.target = target;
      this.usedInAst = usedInAst;
      this.direct = direct;
      this.ignored = ignored;
    }
  }
}
