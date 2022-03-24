package scalarules.test.junit.runtime_platform;

import org.junit.Assert;
import org.junit.Test;

public class JunitRuntimePlatformTest {

  @Test
  public void someTest() {
    String expectedMajorVersion = "11";
    String version = System.getProperty("java.version");
    boolean majorVersionMatches = version.startsWith(expectedMajorVersion + ".");
    String failureMsg = "Expected major version of " + expectedMajorVersion + " but got version: " + version;
    Assert.assertTrue(failureMsg, majorVersionMatches);
  }
}
