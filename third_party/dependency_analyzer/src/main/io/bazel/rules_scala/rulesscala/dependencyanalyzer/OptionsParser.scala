package third_party.dependency_analyzer.src.main.io.bazel.rules_scala.dependencyanalyzer

import scala.collection.mutable

object OptionsParser {
  def create(
    options: List[String],
    error: String => Unit
  ): OptionsParser = {
    val optionsMap = mutable.Map[String, String]()
    options.foreach { option =>
      option.split(":", 2) match {
        case Array(key) =>
          error(s"Argument $key missing value")
        case Array(key, value) =>
          if (optionsMap.contains(key)) {
            error(s"Argument $key found multiple times")
          }
          optionsMap.put(key, value)
      }
    }

    new OptionsParser(error = error, options = optionsMap)
  }
}

class OptionsParser private(
  error: String => Unit,
  options: mutable.Map[String, String]
) {
  def failOnUnparsedOptions(): Unit = {
    options.keys.foreach { key =>
      error(s"Unrecognized option $key")
    }
  }

  def takeStringOpt(key: String): Option[String] = {
    options.remove(key)
  }

  def takeString(key: String): String = {
    takeStringOpt(key).getOrElse {
      error(s"Missing required option $key")
      "NA"
    }
  }

  def takeStringSeqOpt(key: String): Option[Seq[String]] = {
    takeStringOpt(key).map(_.split(":"))
  }
}
