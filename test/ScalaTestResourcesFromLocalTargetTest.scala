package scalarules.test

import org.scalatest.flatspec._

class ScalaTestResourcesFromLocalTargetTest extends AnyFlatSpec {
  "scala_test's resources when referencing local target" should 
    "assert that local target is not placed in bazel-out, but rather next to the packaged code" in {

      val fileExt = if (isWindows)  ".exe" else ""
      assert(getClass.getResource("/bazel-out/darwin-fastbuild/bin/test/py_resource_binary" + fileExt) == null)
      assert(getClass.getResource("/test/py_resource_binary"+ fileExt) != null)
    }

  def isWindows = System.getProperty("os.name").toLowerCase.contains("windows")
}
