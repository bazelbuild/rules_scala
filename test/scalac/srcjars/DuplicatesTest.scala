package scalarules.test.scalac.srcjars

import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.must.Matchers._
import test.{A, ADuplicate}

class DuplicatesTest extends AnyFunSuite {
  test("all classes from duplicated files are available") {
    noException should be thrownBy classOf[A]
    noException should be thrownBy classOf[ADuplicate]
  }
}
