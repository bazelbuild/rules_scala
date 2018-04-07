package io.bazel.rulesscala.scalac;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CompileOptions {
  final public String outputName;
  final public String manifestPath;
  final public String[] scalaOpts;
  final public boolean printCompileTime;
  final public String[] pluginArgs;
  final public String classpath;
  final public String[] files;
  final public String[] sourceJars;
  final public boolean iJarEnabled;
  final public String ijarOutput;
  final public String ijarCmdPath;
  final public String[] javaFiles;
  final public Map<String, Resource> resourceFiles;
  final public String resourceStripPrefix;
  final public String[] resourceJars;
  final public String[] classpathResourceFiles;
  final public String[] directJars;
  final public String[] indirectJars;
  final public String[] indirectTargets;
  final public String dependencyAnalyzerMode;
  final public String currentTarget;
  final public String statsfile;

  public CompileOptions(List<String> args) {
    Map<String, String> argMap = buildArgMap(args);

    outputName = getOrError(argMap, "JarOutput", "Missing required arg JarOutput");
    manifestPath = getOrError(argMap, "Manifest", "Missing required arg Manifest");

    scalaOpts = getCommaList(argMap, "ScalacOpts");
    printCompileTime = booleanGetOrFalse(argMap, "PrintCompileTime");
    pluginArgs = buildPluginArgs(getOrEmpty(argMap, "Plugins"));
    classpath = getOrError(argMap, "Classpath", "Must supply the classpath arg");
    files = getCommaList(argMap, "Files");

    javaFiles = getCommaList(argMap, "JavaFiles");

    sourceJars = getCommaList(argMap, "SourceJars");
    iJarEnabled = booleanGetOrFalse(argMap, "EnableIjar");
    if(iJarEnabled) {
     ijarOutput = getOrError(argMap, "IjarOutput", "Missing required arg ijarOutput when ijar enabled");
     ijarCmdPath = getOrError(argMap, "IjarCmdPath", "Missing required arg ijarCmdPath when ijar enabled");
    }
    else {
      ijarOutput = null;
      ijarCmdPath = null;
    }
    resourceFiles = getResources(argMap);
    resourceStripPrefix = getOrEmpty(argMap, "ResourceStripPrefix");
    resourceJars = getCommaList(argMap, "ResourceJars");
    classpathResourceFiles = getCommaList(argMap, "ClasspathResourceSrcs");

    directJars = getCommaList(argMap, "DirectJars");
    indirectJars = getCommaList(argMap, "IndirectJars");
    indirectTargets = getCommaList(argMap, "IndirectTargets");

    dependencyAnalyzerMode = getOrElse(argMap, "DependencyAnalyzerMode", "off");
    currentTarget = getOrElse(argMap, "CurrentTarget", "NA");

    statsfile = getOrError(argMap, "StatsfileOutput", "Missing required arg StatsfileOutput");
  }

  private static Map<String, Resource> getResources(Map<String, String> args) {
    String[] keys = getCommaList(args, "ResourceSrcs");
    String[] dests = getCommaList(args, "ResourceDests");
    String[] shortPaths = getCommaList(args, "ResourceShortPaths");

    if (keys.length != dests.length)
      throw new RuntimeException(String.format("mismatch in resources: keys: %s dests: %s",
            getOrEmpty(args, "ResourceSrcs"), getOrEmpty(args, "ResourceDests")));

    if (keys.length != shortPaths.length)
      throw new RuntimeException(String.format("mismatch in resources: keys: %s shortPaths: %s",
            getOrEmpty(args, "ResourceSrcs"), getOrEmpty(args, "ResourceShortPaths")));

    HashMap<String, Resource> res = new HashMap();
    for(int idx = 0; idx < keys.length; idx++) {
      Resource resource = new Resource(dests[idx], shortPaths[idx]);
      res.put(keys[idx], resource);
    }
    return res;
  }

  private static HashMap<String, String> buildArgMap(List<String> lines) {
    HashMap hm = new HashMap();
    for(String line: lines) {
      String[] lSplit = line.split(": ");
      if(lSplit.length > 2) {
        throw new RuntimeException("Bad arg, should have at most 1 space/2 spans. arg: " + line);
      }
      if(lSplit.length > 1) {
        hm.put(lSplit[0], lSplit[1]);
      }
    }
    return hm;
  }

  private static String[] getCommaList(Map<String, String> m, String k) {
    if(m.containsKey(k)) {
      String v = m.get(k);
      if ("".equals(v)) {
        return new String[]{};
      }
      else {
        return v.split(",");
      }
    } else {
      return new String[]{};
    }
  }

  private static String getOrEmpty(Map<String, String> m, String k) {
    return getOrElse(m, k, "");
  }

  private static String getOrElse(Map<String, String> attrs, String key, String defaultValue) {
    if(attrs.containsKey(key)) {
      return attrs.get(key);
    } else {
      return defaultValue;
    }
  }

  private static String getOrError(Map<String, String> m, String k, String errorMessage) {
    if(m.containsKey(k)) {
      return m.get(k);
    } else {
      throw new RuntimeException(errorMessage);
    }
  }

  private static boolean booleanGetOrFalse(Map<String, String> m, String k) {
    if(m.containsKey(k)) {
      String v = m.get(k);
      if(v.trim().equals("True") || v.trim().equals("true")) {
        return true;
      }
    }
    return false;
  }
  public static String[] buildPluginArgs(String packedPlugins) {
    String[] pluginElements = packedPlugins.split(",");
    int numPlugins = 0;
    for(int i =0; i< pluginElements.length; i++){
      if(pluginElements[i].length() > 0) {
        numPlugins += 1;
      }
    }

    String[] result = new String[numPlugins];
    int idx = 0;
    for(int i =0; i< pluginElements.length; i++){
      if(pluginElements[i].length() > 0) {
        result[idx] = "-Xplugin:" + pluginElements[i];
        idx += 1;
      }
    }
    return result;
  }
}
