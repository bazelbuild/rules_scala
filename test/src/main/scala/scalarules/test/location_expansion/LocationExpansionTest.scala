package scalarules.test.location_expansion

import org.specs2.mutable.SpecWithJUnit
class LocationExpansionTest extends SpecWithJUnit {

  "tests" >> {
    "support location expansion" >> {
      sys.props.get("location.expanded") must beSome(contain("worker"))

    }
  }
  

}
