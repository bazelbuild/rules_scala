package foo

object AddNumbers {
  def addUntil1000: Int = {
    (0 until 1000).reduce(_ + _)
  }
}
