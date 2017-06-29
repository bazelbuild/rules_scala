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
  final public String javacPath;
  final public String javacOpts;
  final public Map<String, String> resourceFiles;
  final public String resourceStripPrefix;
  final public String[] resourceJars;

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
    javacPath = getOrEmpty(argMap, "JavacPath");
    javacOpts = getOrEmpty(argMap, "JavacOpts");

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
  }

  private static Map<String, String> getResources(Map<String, String> args) {
    String[] keys = getCommaList(args, "ResourceSrcs");
    String[] vals = getCommaList(args, "ResourceDests");
    if (keys.length != vals.length)
      throw new RuntimeException(String.format("mismatch in resources: keys: %s vals: %s",
            getOrEmpty(args, "ResourceSrcs"), getOrEmpty(args, "ResourceDests")));
    HashMap<String, String> res = new HashMap();
    for(int idx = 0; idx < keys.length; idx++) {
      res.put(keys[idx], vals[idx]);
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
    if(m.containsKey(k)) {
      return m.get(k);
    } else {
      return "";
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
