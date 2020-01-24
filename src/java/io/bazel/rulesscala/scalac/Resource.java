package io.bazel.rulesscala.scalac;

public class Resource {
  public final String target;
  public final String source;

  public Resource(String target, String source) {
    this.target = target;
    this.source = source;
  }
}
