package io.bazel.rulesscala.scalac;

import java.util.Arrays;
import java.util.LinkedHashMap;

public class CompileOptions {
    public final String outputName;
    public final String manifestPath;
    public final String[] scalaOpts;
    public final boolean printCompileTime;
    public final boolean expectJavaOutput;
    public final String[] plugins;
    public final String[] classpath;
    public final String[] files;
    public final String[] sourceJars;
    public final String[] javaFiles;
    public final String[] resourceSources;
    public final String[] resourceTargets;
    public final String[] resourceJars;
    public final String[] classpathResourceFiles;
    public final String[] directJars;
    public final String[] directTargets;
    public final String[] unusedDepsIgnoredTargets;
    public final String[] indirectJars;
    public final String[] indirectTargets;
    public final String strictDepsMode;
    public final String unusedDependencyCheckerMode;
    public final String currentTarget;
    public final String statsfile;
    public final String dependencyTrackingMethod;
    public final String diagnosticsFile;
    public final boolean enableDiagnosticsReport;

    public CompileOptions(String[] args) {
        ArgMap argMap = new ArgMap(args);

        outputName = argMap.getSingleOrError("JarOutput");
        manifestPath = argMap.getSingleOrError("Manifest");

        scalaOpts = argMap.getOrEmpty("ScalacOpts");
        printCompileTime = Boolean.parseBoolean(argMap.getSingleOrError("PrintCompileTime"));
        expectJavaOutput = Boolean.parseBoolean(argMap.getSingleOrError("ExpectJavaOutput"));
        plugins = argMap.getOrEmpty("Plugins");
        classpath = argMap.getOrEmpty("Classpath");
        files = argMap.getOrEmpty("Files");
        sourceJars = argMap.getOrEmpty("SourceJars");
        javaFiles = argMap.getOrEmpty("JavaFiles");

        resourceSources = argMap.getOrEmpty("ResourceSources");
        resourceTargets = argMap.getOrEmpty("ResourceTargets");
        resourceJars = argMap.getOrEmpty("ResourceJars");
        classpathResourceFiles = argMap.getOrEmpty("ClasspathResourceSrcs");

        directJars = argMap.getOrEmpty("DirectJars");
        directTargets = argMap.getOrEmpty("DirectTargets");
        unusedDepsIgnoredTargets = argMap.getOrEmpty("UnusedDepsIgnoredTargets");
        indirectJars = argMap.getOrEmpty("IndirectJars");
        indirectTargets = argMap.getOrEmpty("IndirectTargets");

        strictDepsMode = argMap.getSingleOrError("StrictDepsMode");
        unusedDependencyCheckerMode = argMap.getSingleOrError("UnusedDependencyCheckerMode");
        currentTarget = argMap.getSingleOrError("CurrentTarget");
        dependencyTrackingMethod = argMap.getSingleOrError("DependencyTrackingMethod");

        statsfile = argMap.getSingleOrError("StatsfileOutput");
        enableDiagnosticsReport = Boolean.parseBoolean(argMap.getSingleOrError("EnableDiagnosticsReport"));
        diagnosticsFile = argMap.getSingleOrError("DiagnosticsFile");
    }

    static final class ArgMap extends LinkedHashMap<String, String[]> {

        private static final String[] EMPTY = new String[]{};

        ArgMap(String[] lines) {
            int opt = 0;
            for (int i = 1, n = lines.length; i <= n; i++) {
                if (i == n || lines[i].startsWith("--")) {
                    this.put(
                            lines[opt].substring(2),
                            Arrays.copyOfRange(lines, opt + 1, i)
                    );
                    opt = i;
                }
            }
        }

        String[] getOrEmpty(String k) {
            return this.getOrDefault(k, EMPTY);
        }

        String getSingleOrError(String k) {
            if (this.containsKey(k)) {
                String[] v = this.get(k);
                if (v.length == 1) {
                    return v[0];
                } else {
                    throw new RuntimeException(k + " expected to contain single value but got " + Arrays.toString(v));
                }
            } else {
                throw new RuntimeException("Missing required arg " + k);
            }
        }
    }
}
