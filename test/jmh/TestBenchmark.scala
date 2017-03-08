package foo

import org.openjdk.jmh.annotations.Benchmark

class TestBenchmark {
  @Benchmark
  def sumIntegersBenchmark: Int = {
    (0 until 1000).reduce(_ + _)
  }
}