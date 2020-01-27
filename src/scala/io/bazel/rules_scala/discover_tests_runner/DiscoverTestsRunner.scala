package io.bazel.rules_scala.discover_tests_runner

import io.bazel.rules_scala.worker.Worker

object DiscoverTestsRunner extends Worker.Interface {

  def main(args: Array[String]): Unit = Worker.workerMain(args, DiscoverTestsWorker)

  def work(args: Array[String]): Unit = {
    println("WORK WORK WORK")
  }
}
