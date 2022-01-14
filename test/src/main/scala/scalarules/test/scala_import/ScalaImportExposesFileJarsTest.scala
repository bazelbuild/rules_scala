package scalarules.test.scala_import

import org.specs2.mutable.SpecificationWithJUnit
import com.lucidchart.relate.SqlRow

class ScalaImportExposesJarsTest extends SpecificationWithJUnit {

  "scala_import" >> {
    "enable importing jars from files" in {
      println(classOf[SqlRow])
      success
    }
  }

}
