package io.bazel.rules_scala.test_discovery

import io.bazel.rules_scala.worker.Worker

import io.github.classgraph.ClassGraph

object TestDiscoveryWorker extends Worker.Interface {

  def main(args: Array[String]): Unit = Worker.workerMain(args, TestDiscoveryWorker)

  def work(args: Array[String]): Unit = {
    println("WORK IT")

    val cg = new ClassGraph()
  }
}
