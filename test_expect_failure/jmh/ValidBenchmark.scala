package foo

import org.openjdk.jmh.annotations.Benchmark

class ValidBenchmark {
  @Benchmark
  def sumIntegersBenchmark: Int =
    (1 to 100).sum
}
