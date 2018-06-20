package scalarules.test.twitter_scrooge

import scalarules.test.twitter_scrooge.thrift.thrift2.thrift3.Struct3

object Twodeep {
  val classes =
    Seq(
      classOf[Struct3],
      JustScrooge3.getClass
    )

  def main(args: Array[String]) {
    classes foreach println
  }
}
