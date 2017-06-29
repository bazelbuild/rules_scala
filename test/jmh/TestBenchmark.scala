package foo

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}

class TestBenchmark {
  @State(Scope.Benchmark)
  class BenchmarkState {
    val myScalaType = ScalaType(100)
    val myJavaType = new JavaType
  }

  @Benchmark
  def sumIntegersBenchmark: Int =
    AddNumbers.addUntil1000
}