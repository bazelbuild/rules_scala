package coverage_filename_encoding

import org.specs2.mutable.SpecWithJUnit
import org.specs2.specification.Scope

class Test extends SpecWithJUnit {
  "testA1" in new Scope {
    A1.a1(true) must_!= 1
  }
}
