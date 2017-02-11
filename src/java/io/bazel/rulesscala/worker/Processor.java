package io.bazel.rulesscala.worker;

import java.util.List;

public interface Processor {
  void processRequest(List<String> args) throws Exception;
}
