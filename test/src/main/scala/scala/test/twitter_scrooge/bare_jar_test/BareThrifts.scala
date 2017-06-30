package scala.test.twitter_scrooge

import com.foo.bar.baz.Foo

object BareThrifts {
  val classes = Seq(classOf[Foo])

  def main(args: Array[String]) {
    print(s"classes ${classes.mkString(",")}")
  }
}
