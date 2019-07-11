package scalarules.test.src.main.scala.scalarules.test.compiler_plugin

import scala.language.higherKinds

class HKT[F[_]]
class KKTImpl extends HKT[Either[String, ?]]