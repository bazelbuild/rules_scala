package io.bazel.rulesscala

import org.junit.runner.Description
import org.specs2.concurrent.ExecutionEnv
import org.specs2.reporter.JUnitDescriptions
import org.specs2.specification.core.{Fragment, SpecStructure}

package object specs2 {
  type specs2_v4 = {
    def fragmentDescriptions(spec: SpecStructure)(ee: ExecutionEnv): Map[Fragment, Description]
  }
  type specs2_v3 = {
    def fragmentDescriptions(spec: SpecStructure): Map[Fragment, Description]
  }

  def allDescriptions[T] = JUnitDescriptions.asInstanceOf[T]
}
