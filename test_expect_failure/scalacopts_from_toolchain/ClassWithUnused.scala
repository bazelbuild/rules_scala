package test_expect_failure.scalacopts_from_toolchain

class ClassWithUnused(name:String){
  def talk():String = {
    val unusedValue = "I am not used :-("
    s"hello $name"
  }
}