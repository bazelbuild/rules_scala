package scalarules.test.scalafmt
object Format {
  def main(args: Array[String]) {
    val warnings: List[String] = List(
      "Be careful with this test",
      "小心這個測試",
      "このテストに注意してください",
      "이 시험에 조심하십시오",
      "😁✊🚀🍟💯", //mind the trailing commas
    )
  }
}
