package io.bazel.rules_scala.discover_tests_worker

import io.bazel.rules_scala.worker.Worker

import io.github.classgraph.ClassGraph

object DiscoverTestsWorker extends Worker.Interface {

  def main(args: Array[String]): Unit = Worker.workerMain(args, DiscoverTestsWorker)

  def work(args: Array[String]): Unit = {
    println("WORK IT")

    val cg = new ClassGraph()
  }
}
