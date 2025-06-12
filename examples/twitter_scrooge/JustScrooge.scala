package examples.twitter_scrooge

object JustScrooge {
  val classes = Seq(classOf[Struct1])

  def main(args: Array[String]) {
    print(s"classes ${classes.mkString(",")}")
  }
}
