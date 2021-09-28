package io.bazel.rulesscala.io_utils;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class StreamCopy {

  private static final int BUFFER_SIZE = 1024 * 4;

  public static void copy(InputStream from, OutputStream to) throws IOException {
    byte[] buffer = new byte[BUFFER_SIZE];
    while (true) {
      int readCount = from.read(buffer);
      if (readCount == -1) {
        break;
      }
      to.write(buffer, 0, readCount);
    }
  }
}
