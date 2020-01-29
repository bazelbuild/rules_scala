package io.bazel.rules_scala

import org.junit.runner.Description
import org.specs2.concurrent.ExecutionEnv
import org.specs2.fp.TreeLoc
import org.specs2.reporter.JUnitDescriptions
import org.specs2.specification.core.{Fragment, SpecStructure}

package object specs2 {
  type specs2_v4 = {
    //noinspection ScalaUnusedSymbol
    def createDescriptionTree(spec: SpecStructure)(ee: ExecutionEnv): TreeLoc[(Fragment, Description)]
  }
  type specs2_v3 = {
    //noinspection ScalaUnusedSymbol
    def createDescriptionTree(spec: SpecStructure): TreeLoc[(Fragment, Description)]
  }

  def allDescriptions[T]: T = JUnitDescriptions.asInstanceOf[T]
}