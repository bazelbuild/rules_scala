package repros

import org.specs2.matcher.Matchers

object Specs2MatchersRepro {

  def fooSome(bar: String) = Matchers.beSome(bar)
}