package scalarules.test

class ScalaTestResourcesFromLocalTargetTest extends org.scalatest.FlatSpec {
  "scala_test's resources when referencing local target" should 
    "assert that local target is not placed in bazel-out, but rather next to the packaged code" in {
      assert(getClass.getResource("/bazel-out/darwin-fastbuild/bin/test/py_resource_binary") == null)
      assert(getClass.getResource("/test/py_resource_binary") != null)
    }
}