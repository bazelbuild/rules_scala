
import org.junit.Test

class JunitFailureTest {

  @Test
  def failing: Unit = {
  	throw new RuntimeException("this test knows how to fail")
  }

}
