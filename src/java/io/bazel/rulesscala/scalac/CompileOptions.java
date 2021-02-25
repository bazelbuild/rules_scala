package io.bazel.rulesscala.scalac;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;

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
        Map<String, String[]> argMap = buildArgMap(args);

        outputName = getSingleOrError(argMap, "JarOutput");
        manifestPath = getSingleOrError(argMap, "Manifest");

        scalaOpts = getOrEmpty(argMap, "ScalacOpts");
        printCompileTime = Boolean.parseBoolean(getSingleOrError(argMap, "PrintCompileTime"));
        expectJavaOutput = Boolean.parseBoolean(getSingleOrError(argMap, "ExpectJavaOutput"));
        plugins = getOrEmpty(argMap, "Plugins");
        classpath = getOrEmpty(argMap, "Classpath");
        files = getOrEmpty(argMap, "Files");
        sourceJars = getOrEmpty(argMap, "SourceJars");
        javaFiles = getOrEmpty(argMap, "JavaFiles");

        resourceSources = getOrEmpty(argMap, "ResourceSources");
        resourceTargets = getOrEmpty(argMap, "ResourceTargets");
        resourceJars = getOrEmpty(argMap, "ResourceJars");
        classpathResourceFiles = getOrEmpty(argMap, "ClasspathResourceSrcs");

        directJars = getOrEmpty(argMap, "DirectJars");
        directTargets = getOrEmpty(argMap, "DirectTargets");
        unusedDepsIgnoredTargets = getOrEmpty(argMap, "UnusedDepsIgnoredTargets");
        indirectJars = getOrEmpty(argMap, "IndirectJars");
        indirectTargets = getOrEmpty(argMap, "IndirectTargets");

        strictDepsMode = getSingleOrError(argMap, "StrictDepsMode");
        unusedDependencyCheckerMode = getSingleOrError(argMap, "UnusedDependencyCheckerMode");
        currentTarget = getSingleOrError(argMap, "CurrentTarget");
        dependencyTrackingMethod = getSingleOrError(argMap, "DependencyTrackingMethod");

        statsfile = getSingleOrError(argMap, "StatsfileOutput");
        enableDiagnosticsReport = Boolean.parseBoolean(getSingleOrError(argMap, "EnableDiagnosticsReport"));
        diagnosticsFile = getSingleOrError(argMap, "DiagnosticsFile");
    }

    private static Map<String, String[]> buildArgMap(String[] lines) {
        Map<String, String[]> args = new LinkedHashMap<>();
        int opt = 0;
        for (int i = 1, n = lines.length; i <= n; i++) {
            if (i == n || lines[i].startsWith("--")) {
                args.put(
                        lines[opt].substring(2),
                        Arrays.copyOfRange(lines, opt + 1, i)
                );
                opt = i;
            }
        }
        return args;
    }

    private static final String[] EMPTY = new String[]{};

    private static String[] getOrEmpty(Map<String, String[]> m, String k) {
        return m.getOrDefault(k, EMPTY);
    }

    private static String getSingleOrError(Map<String, String[]> m, String k) {
        if (m.containsKey(k)) {
            String[] v = m.get(k);
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
