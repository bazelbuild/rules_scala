package coverage_filename_encoding

object A1 {
  def a1(flag: Boolean): String =
    if (flag) "B1"
    else sys.error("oh noes")
}
