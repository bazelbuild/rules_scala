package scala.test.twitter_scrooge

import scala.test.twitter_scrooge.thrift.thrift2.{Struct2A, Struct2B}
import scala.test.twitter_scrooge.thrift.thrift2.thrift3.Struct3

object Scrooge2 {
  val classes = Seq(classOf[Struct2A], classOf[Struct2B], classOf[Struct3])
}