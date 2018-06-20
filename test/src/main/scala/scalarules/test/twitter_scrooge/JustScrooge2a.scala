package scalarules.test.twitter_scrooge

import scalarules.test.twitter_scrooge.thrift.thrift2.Struct2A
import scalarules.test.twitter_scrooge.thrift.thrift2.thrift3.Struct3

object JustScrooge2a {
  val classes = Seq(classOf[Struct2A], classOf[Struct3])
}
