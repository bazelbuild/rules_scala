package scalarules.test

object ScalaBinaryJdk11 {
  def main(args: Array[String]): Unit = {
    val expectedMajorVersion = "11";
    val version = System.getProperty("java.version");
    val majorVersionMatches = version.startsWith(expectedMajorVersion + ".");
    val failureMsg = "Expected major version of " + expectedMajorVersion + " but got version: " + version;
    require(majorVersionMatches, failureMsg);
  }
}
