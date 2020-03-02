package foo

import org.openjdk.jmh.annotations.Benchmark

// Benchmark classes cannot be final.
final class InvalidBenchmark {
  @Benchmark
  def sumIntegersBenchmark: Int =
    (1 to 100).sum
}
