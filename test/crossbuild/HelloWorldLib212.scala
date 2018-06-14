package anx
import scala.util.{Either, Right}

trait Hello {
  def hello: String = "hfnos"
  val either: Either[Int, Int] = Right(1)
  either.toOption
}

trait World {
  def world: String = "wptoh"
}
