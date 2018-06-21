package scalarules.test

object Exported {
  def message: String = {
    // terrible, don't do this in real code:
    val msg = Class.forName("scalarules.test.Runtime")
      .newInstance
      .toString
    "you all, everybody. " + msg
  }
}
