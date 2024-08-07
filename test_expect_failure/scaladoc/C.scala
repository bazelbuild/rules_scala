//import cats.syntax.all._

object C {
  def myfunc()  = {
    A.main() //Call into A, which is a transitive dependency of this lib    
  }
}
