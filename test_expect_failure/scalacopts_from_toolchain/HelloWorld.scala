package test_expect_failure.scalacopts_from_toolchain

class HelloWorld(name:String){
  def talk():String = {
    val a = "dsdssd"
    s"hello $name"
  }
}