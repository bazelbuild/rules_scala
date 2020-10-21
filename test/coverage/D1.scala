package coverage

object D1 {
  def veryLongFunctionNameIsHereAaaaaaaaa(): Unit = {
    val l = List("a")
    // This is bad style, but sometimes still happens to Scala developers...
    // For comprehension that will generate classes with very long names (when compiled).
    for {
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
      _ <- l
    } yield {
      ()
    }
  }
}