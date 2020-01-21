package third_party.resource_strip_prefix

class ResourceStripPrefixTest extends org.specs2.mutable.SpecificationWithJUnit {
  "from external repo" in {
    getClass.getResourceAsStream("/nosrc_jar_resource.txt") must not beNull
  }
}
