package scala.test.junit

import org.junit.Test

class FirstFilterTest {
  @Test def method1 { println(this.getClass.getName + "#method1") }
  @Test def method2 { println(this.getClass.getName + "#method2") }
  @Test def method3 { println(this.getClass.getName + "#method3") }
}

class SecondFilterTest {
  @Test def method1 { println(this.getClass.getName + "#method1") }
  @Test def method2 { println(this.getClass.getName + "#method2") }
  @Test def method3 { println(this.getClass.getName + "#method3") }
}

class ThirdFilterTest {
  @Test def method1 { println(this.getClass.getName + "#method1") }
  @Test def method2 { println(this.getClass.getName + "#method2") }
  @Test def method3 { println(this.getClass.getName + "#method3") }
}
