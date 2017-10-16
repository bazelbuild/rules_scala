package io.bazel.rulesscala.scalac;

public class Resource {
  public final String destination;
  public final String shortPath;

  public Resource(String destination, String shortPath) {
    this.destination = destination;
    this.shortPath = shortPath;
  }
}
