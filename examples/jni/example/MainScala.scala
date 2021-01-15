package example;

object MainScala {
  System.loadLibrary("hello-jni")

  def main(args: Array[String]): Unit = {
    val hello = new Hello()
    println(hello.hello("Scala"))
  }
}
