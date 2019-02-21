package foo

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}
import java.nio.file.{Files, Paths}

class TestBenchmark {
  @State(Scope.Benchmark)
  class BenchmarkState {
    val myScalaType = ScalaType(100)
    val myJavaType = new JavaType
  }

  @Benchmark
  def sumIntegersBenchmark: Int =
    AddNumbers.addUntil1000

  @Benchmark
  def fileAccessBenchmark: Unit = {
    val path = Paths.get("test/jmh/data.txt")
    Files.readAllLines(path)
  }
}