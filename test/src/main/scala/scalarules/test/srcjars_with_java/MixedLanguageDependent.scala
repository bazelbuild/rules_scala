package fish

object MixedLanguageDependent {
  final val poem = List(JavaSource.line, ScalaSource.line).mkString("\n")
}