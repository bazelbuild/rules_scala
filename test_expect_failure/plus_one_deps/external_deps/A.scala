package scalarules.test_expect_failure.plus_one_deps.external_deps
import org.springframework.dao.DataAccessException

class A {
  println(classOf[DataAccessException])
}