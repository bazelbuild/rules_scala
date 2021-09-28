package io.bazel.rulesscala.worker;

class ExitTrapped extends RuntimeException {
  final int code;

  ExitTrapped(int code) {
    super();
    this.code = code;
  }
}
