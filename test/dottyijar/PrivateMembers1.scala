package dottyijar

object PrivateMembers {
  private val privateField = ()
  private lazy val privateLazyField = ()

  val publicField = ()
  lazy val publicLazyField = ()

  private def privateMethod: Unit = {}

  def publicMethod: Unit = {}
}
