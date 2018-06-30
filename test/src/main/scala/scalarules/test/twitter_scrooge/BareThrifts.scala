package scalarules.test.twitter_scrooge

import com.foo.bar.baz.Foo
import com.foo.bar.baz.Bar
import com.foo.bar.baz.Baz

object BareThrifts {
  val classes = Seq(classOf[Foo], classOf[Bar], classOf[Baz])

  def main(args: Array[String]) {
    print(s"classes ${classes.mkString(",")}")
  }
}
