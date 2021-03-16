package coverage_specs2

object A1 {
  def a1(flag: Boolean): B1.type =
    if (flag) B1
    else sys.error("oh noes")
}
