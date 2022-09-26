package foo

import org.openjdk.jmh.annotations.{Benchmark, Warmup, Measurement, Fork}

class TestJmhRuntimeJdk11 {
  @Benchmark
  @Fork(0) // So that System.exit affects main process
  @Warmup(iterations = 0)
  @Measurement(iterations = 1)
  def isUsingJdk11: Unit = {
    val expectedMajorVersion = "11";
    val version = System.getProperty("java.version");
    val majorVersionMatches = version.startsWith(expectedMajorVersion);
    val failureMsg = "Expected major version of " + expectedMajorVersion + " but got version: " + version;
    
    if (!majorVersionMatches) {
      println(failureMsg);
      // Our JMH doesn't fail on exception; we have to manually exit
      // Perhaps we should consider an attr on scala_benchmark_jmh for failing on exception (JMH flag -foe)
      System.exit(1);
    }
  }
}