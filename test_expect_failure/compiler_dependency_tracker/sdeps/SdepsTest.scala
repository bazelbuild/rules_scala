package sdeps

import org.specs2.mutable.SpecWithJUnit
import io.bazel.rulesscala.deps.proto.ScalaDeps
import io.bazel.rulesscala.deps.proto.ScalaDeps.Dependency.Kind._
import org.specs2.matcher.Matcher

import java.util

class SdepsTest extends SpecWithJUnit {

  "Mixed Scala/Java source targets" should {
    val deps = loadSdeps("mixed_sources.sdeps")

    "mark unused deps as ignored" in {
      val unusedDep = findDep(deps, ":scala_unused_dep")

      unusedDep must (beIgnored and beUnused)
    }

    "mark ignored deps as ignored" in {
      val ignoredDep = findDep(deps, ":scala_ignored_unused_dep")

      ignoredDep must (beIgnored and beUnused)
    }
  }

  "Scala-only source targets" should {
    val deps = loadSdeps("only_scala_sources.sdeps")

    "mark unused deps as not ignored" in {
      val unusedDep = findDep(deps, ":scala_unused_dep")

      unusedDep must (not(beIgnored) and beUnused)
    }

    "mark ignored deps as ignored" in {
      val ignoredDep = findDep(deps, ":scala_ignored_unused_dep")

      ignoredDep must (beIgnored and beUnused)
    }
  }

  def beIgnored: Matcher[ScalaDeps.Dependency] = {
    beTrue ^^ { (_: ScalaDeps.Dependency).getIgnored }
  }

  def beUnused: Matcher[ScalaDeps.Dependency] = {
    be_==(UNUSED) ^^ { (_: ScalaDeps.Dependency).getKind }
  }

  def loadSdeps(resource: String): util.List[ScalaDeps.Dependency] = {
    val prefix = "/test_expect_failure/compiler_dependency_tracker/sdeps/"
    val is = getClass.getResourceAsStream(prefix + resource)
    ScalaDeps.Dependencies.parseFrom(is).getDependencyList
  }

  def findDep(deps: util.List[ScalaDeps.Dependency], byLabelSuffix: String): ScalaDeps.Dependency =
    deps.stream()
      .filter(_.getLabel.endsWith(byLabelSuffix))
      .findFirst()
      .orElseThrow(
        () => new RuntimeException(byLabelSuffix + " dep not reported in the sdeps file")
      )
}
