package scala.tools.cmd;

// Hack due to CommandLineParser disappearing in Scala 2.13.9:
// https://github.com/scala/scala/pull/10057
object CommandLineParser {
    def tokenize(line: String): List[String] = scala.sys.process.Parser
        .tokenize(line)
}
