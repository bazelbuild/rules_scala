package scalarules.test;

//import scala.Option; //having an import isn't sufficient
import scalarules.test.ScalaCase; //must, if we just have a usage (commented out below) doesn't reproduce

public class JavaClass {

  public static void foo(scala.Option scalaType) {
    //scala.Option.empty(); //this usage of scala type doesn't show the issue, only in method signature
    //new ScalaCase();  //this usage of ScalaCase doesn't show the issue
  }

}