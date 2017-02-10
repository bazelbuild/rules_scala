package scala.test;

import org.junit.Assert;
import org.junit.Test;

public class NativeTestJava {
  @Test
  public void testLoad() {
    System.out.println("java.library.path: " + System.getProperty("java.library.path"));
    try {
      System.loadLibrary("NativeLibCompiledElsewhere");
    } catch (UnsatisfiedLinkError e) {
      Assert.fail("Can't load NativeLibCompiledElsewhere");
    }
  }
}
