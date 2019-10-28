package test.scalafmt
object Utf8FormatTest {
  def main(args: Array[String]) {
    val warning1: String = "Be careful with this test"
    val warning2: String =  "小心這個測試"
    val warning3: String =   "このテストに注意してください"
    val warning4: String =    "이 시험에 조심하십시오"
    val warning5: String =     "كن حذرا مع هذا الاختبار"
    val warning6: String =      "Hãy cẩn thận với bài kiểm tra này"
    val warning7: String =       "Будьте осторожны с этим тестом"
    val warning8: String =        "😁✊🚀🍟💯"
  }
}
