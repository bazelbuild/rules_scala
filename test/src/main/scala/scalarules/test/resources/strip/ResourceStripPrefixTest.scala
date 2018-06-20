package scalarules.test.resources.strip

import org.specs2.mutable.SpecificationWithJUnit

class ResourceStripPrefixTest extends SpecificationWithJUnit {

  "resource_strip_prefix" should {
    "strip the prefix on nosrc jar" in {
      val resource = getClass.getResourceAsStream("/nosrc_jar_resource.txt")
      resource must not beNull
    }
  }

}
