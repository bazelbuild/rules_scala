package scalarules.test.scala_test

import org.scalatest._
import org.scalatest.events.Event

class CustomReporter extends Reporter {
  override def apply(event: Event): Unit = {
  }
}