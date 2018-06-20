package scalarules.test.twitter_scrooge

import scalarules.test.twitter_scrooge.thrift.Struct1
import scalarules.test.twitter_scrooge.thrift.thrift2.Struct2A
import scalarules.test.twitter_scrooge.thrift.thrift2.Struct2B
import scalarules.test.twitter_scrooge.thrift.thrift2.thrift3.Struct3

object Mixed {
  val classes =
    Seq(
      classOf[Struct1],
      classOf[Struct2A],
      classOf[Struct2B],
      classOf[Struct3],
      JustScrooge1.getClass,
      JustScrooge2a.getClass,
      JustScrooge2b.getClass,
      JustScrooge3.getClass
    )
}
