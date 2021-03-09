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
    public final String stampLabel;
    public final String statsfile;
    public final String dependencyTrackingMethod;
    public final String diagnosticsFile;
    public final boolean enableDiagnosticsReport;

    public CompileOptions(String[] lines) {
        Args args = new Args(lines);

        outputName = args.getSingleOrError("JarOutput");
        manifestPath = args.getSingleOrError("Manifest");

        scalaOpts = args.getOrEmpty("ScalacOpts");
        printCompileTime = Boolean.parseBoolean(args.getSingleOrError("PrintCompileTime"));
        expectJavaOutput = Boolean.parseBoolean(args.getSingleOrError("ExpectJavaOutput"));
        plugins = args.getOrEmpty("Plugins");
        classpath = args.getOrEmpty("Classpath");
        files = args.getOrEmpty("Files");
        sourceJars = args.getOrEmpty("SourceJars");
        javaFiles = args.getOrEmpty("JavaFiles");

        resourceSources = args.getOrEmpty("ResourceSources");
        resourceTargets = args.getOrEmpty("ResourceTargets");
        resourceJars = args.getOrEmpty("ResourceJars");
        classpathResourceFiles = args.getOrEmpty("ClasspathResourceSrcs");

        directJars = args.getOrEmpty("DirectJars");
        directTargets = args.getOrEmpty("DirectTargets");
        unusedDepsIgnoredTargets = args.getOrEmpty("UnusedDepsIgnoredTargets");
        indirectJars = args.getOrEmpty("IndirectJars");
        indirectTargets = args.getOrEmpty("IndirectTargets");

        strictDepsMode = args.getSingleOrError("StrictDepsMode");
        unusedDependencyCheckerMode = args.getSingleOrError("UnusedDependencyCheckerMode");
        currentTarget = args.getSingleOrError("CurrentTarget");
        stampLabel = args.getSingleOrError("StampLabel");
        dependencyTrackingMethod = args.getSingleOrError("DependencyTrackingMethod");

        statsfile = args.getSingleOrError("StatsfileOutput");
        enableDiagnosticsReport = Boolean.parseBoolean(args.getSingleOrError("EnableDiagnosticsReport"));
        diagnosticsFile = args.getSingleOrError("DiagnosticsFile");
    }

    static final class Args {

        private static final String[] EMPTY = new String[]{};
        private final Map<String, String[]> index = new LinkedHashMap<>();

        Args(String[] lines) {
            int opt = 0;
            for (int i = 1, n = lines.length; i <= n; i++) {
                if (i == n || lines[i].startsWith("--")) {
                    index.put(
                            lines[opt].substring(2),
                            Arrays.copyOfRange(lines, opt + 1, i)
                    );
                    opt = i;
                }
            }
        }

        String[] getOrEmpty(String k) {
            return index.getOrDefault(k, EMPTY);
        }

        String getSingleOrError(String k) {
            if (index.containsKey(k)) {
                String[] v = index.get(k);
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
