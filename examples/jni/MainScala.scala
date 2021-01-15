package examples.jni;

object MainScala {
  System.loadLibrary("hello-jni")

  def main(args: Array[String]): Unit = {
    val hello = new Hello()
    println(hello.hello("Scala"))
  }
}
