package io.bazel.rulesscala.scalac;

import java.util.*;

import static java.util.Arrays.copyOfRange;

public class CompileOptions {
    public final String outputName;
    public final String manifestPath;
    public final String[] scalaOpts;
    public final boolean printCompileTime;
    public final boolean expectJavaOutput;
    public final String[] pluginArgs;
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

        outputName = getOrError(argMap, "JarOutput", "Missing required arg JarOutput");
        manifestPath = getOrError(argMap, "Manifest", "Missing required arg Manifest");

        scalaOpts = getCommaList(argMap, "ScalacOpts");
        printCompileTime = booleanGetOrFalse(argMap, "PrintCompileTime");
        expectJavaOutput = booleanGetOrTrue(argMap, "ExpectJavaOutput");
        pluginArgs = buildPluginArgs(getCommaList(argMap, "Plugins"));
        classpath = getCommaList(argMap, "Classpath");
        files = getCommaList(argMap, "Files");

        javaFiles = getCommaList(argMap, "JavaFiles");

        if (!expectJavaOutput && javaFiles.length != 0) {
            throw new RuntimeException("Cannot hava java source files when no expected java output");
        }

        sourceJars = getCommaList(argMap, "SourceJars");
        resourceSources = getCommaList(argMap, "ResourceSources");
        resourceTargets = getCommaList(argMap, "ResourceTargets");

        if (resourceSources.length != resourceTargets.length)
            throw new RuntimeException(
                    String.format(
                            "mismatch in resources: targets: %s sources: %s",
                            Arrays.toString(resourceTargets), Arrays.toString(resourceSources)));

        resourceJars = getCommaList(argMap, "ResourceJars");
        classpathResourceFiles = getCommaList(argMap, "ClasspathResourceSrcs");

        directJars = getCommaList(argMap, "DirectJars");
        directTargets = getCommaList(argMap, "DirectTargets");
        unusedDepsIgnoredTargets = getCommaList(argMap, "UnusedDepsIgnoredTargets");
        indirectJars = getCommaList(argMap, "IndirectJars");
        indirectTargets = getCommaList(argMap, "IndirectTargets");

        strictDepsMode = getOrElse(argMap, "StrictDepsMode", "off");
        unusedDependencyCheckerMode = getOrElse(argMap, "UnusedDependencyCheckerMode", "off");
        currentTarget = getOrElse(argMap, "CurrentTarget", "NA");
        dependencyTrackingMethod = getOrElse(argMap, "DependencyTrackingMethod", "high-level");

        statsfile = getOrError(argMap, "StatsfileOutput", "Missing required arg StatsfileOutput");
        enableDiagnosticsReport = booleanGetOrFalse(argMap, "EnableDiagnosticsReport");
        diagnosticsFile = getOrError(argMap, "DiagnosticsFile", "Missing required arg DiagnosticsFile");
    }

    private static Map<String, String[]> buildArgMap(String[] lines) {
        Map<String, String[]> args = new LinkedHashMap<>();
        int opt = 0;
        for (int i = 1; i <= lines.length; i++) {
            if (i == lines.length || lines[i].startsWith("--")) {
                args.put(
                        lines[opt].substring(2),
                        copyOfRange(lines, opt + 1, i)
                );
                opt = i;
            }
        }
        return args;
    }

    private static String[] getCommaList(Map<String, String[]> m, String k) {
        return m.getOrDefault(k, new String[]{});
    }

    private static String getOrElse(Map<String, String[]> attrs, String key, String defaultValue) {
        if (attrs.containsKey(key)) {
            return attrs.get(key)[0];
        } else {
            return defaultValue;
        }
    }

    private static String getOrError(Map<String, String[]> m, String k, String errorMessage) {
        if (m.containsKey(k)) {
            return m.get(k)[0];
        } else {
            throw new RuntimeException(errorMessage);
        }
    }

    private static boolean booleanGetOrFalse(Map<String, String[]> m, String k) {
        if (m.containsKey(k)) {
            String v = m.get(k)[0];
            if (v.trim().equals("True") || v.trim().equals("true")) {
                return true;
            }
        }
        return false;
    }

    private static boolean booleanGetOrTrue(Map<String, String[]> m, String k) {
        if (m.containsKey(k)) {
            String v = m.get(k)[0];
            if (v.trim().equals("False") || v.trim().equals("false")) {
                return false;
            }
        }
        return true;
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
}
