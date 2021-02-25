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

        outputName = getOrError(argMap, "JarOutput");
        manifestPath = getOrError(argMap, "Manifest");

        scalaOpts = getCommaList(argMap, "ScalacOpts");
        printCompileTime = Boolean.parseBoolean(getOrError(argMap, "PrintCompileTime"));
        expectJavaOutput = Boolean.parseBoolean(getOrError(argMap, "ExpectJavaOutput"));
        plugins = getCommaList(argMap, "Plugins");
        classpath = getCommaList(argMap, "Classpath");
        files = getCommaList(argMap, "Files");

        javaFiles = getCommaList(argMap, "JavaFiles");

        sourceJars = getCommaList(argMap, "SourceJars");
        resourceSources = getCommaList(argMap, "ResourceSources");
        resourceTargets = getCommaList(argMap, "ResourceTargets");

        resourceJars = getCommaList(argMap, "ResourceJars");
        classpathResourceFiles = getCommaList(argMap, "ClasspathResourceSrcs");

        directJars = getCommaList(argMap, "DirectJars");
        directTargets = getCommaList(argMap, "DirectTargets");
        unusedDepsIgnoredTargets = getCommaList(argMap, "UnusedDepsIgnoredTargets");
        indirectJars = getCommaList(argMap, "IndirectJars");
        indirectTargets = getCommaList(argMap, "IndirectTargets");

        strictDepsMode = getOrError(argMap, "StrictDepsMode");
        unusedDependencyCheckerMode = getOrError(argMap, "UnusedDependencyCheckerMode");
        currentTarget = getOrError(argMap, "CurrentTarget");
        dependencyTrackingMethod = getOrError(argMap, "DependencyTrackingMethod");

        statsfile = getOrError(argMap, "StatsfileOutput");
        enableDiagnosticsReport = Boolean.parseBoolean(getOrError(argMap, "EnableDiagnosticsReport"));
        diagnosticsFile = getOrError(argMap, "DiagnosticsFile");
    }

    private static Map<String, String[]> buildArgMap(String[] lines) {
        Map<String, String[]> args = new LinkedHashMap<>();
        int opt = 0;
        for (int i = 1; i <= lines.length; i++) {
            if (i == lines.length || lines[i].startsWith("--")) {
                args.put(
                        lines[opt].substring(2),
                        Arrays.copyOfRange(lines, opt + 1, i)
                );
                opt = i;
            }
        }
        return args;
    }

    private static String[] getCommaList(Map<String, String[]> m, String k) {
        return m.getOrDefault(k, new String[]{});
    }

    private static String getOrError(Map<String, String[]> m, String k) {
        if (m.containsKey(k)) {
            return m.get(k)[0];
        } else {
            throw new RuntimeException("Missing required arg " + k);
        }
    }
}
