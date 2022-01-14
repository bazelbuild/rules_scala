package coverage_filename_encoding

import org.specs2.mutable.SpecWithJUnit

class Test extends SpecWithJUnit {
  "testA1" in {
    A1.a1(true) must be_!=(1)
  }
}
