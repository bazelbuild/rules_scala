import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.must.Matchers
import io.bazel.rulesscala.dependencyanalyzer.OptionsParser;

class TargetSetParserTest extends AnyFlatSpec with Matchers {

  //Test parsing of ';' delimited string with escapes
  "OptionsParser" should "handle ; as escaped delimiter" in {
    
    val result = OptionsParser.decodeStringSeqOpt(";//Pkg:tgt1\\;23;f;;;g;");
    val expectedList = Seq[String]("//Pkg:tgt1;23", "f", "g");
    assert(result === expectedList);
  }

    //Test parsing of ';' delimited string with escapes
  "OptionsParser" should "handle ; as escaped delimiter (end in escape)" in {
    
    val result = OptionsParser.decodeStringSeqOpt(";Tgt1;tgt2\\;");
    val expectedList = Seq[String]("Tgt1", "tgt2;");
    assert(result === expectedList);
  }

  "OptionsParser" should "handle empty string" in {
    
    val result = OptionsParser.decodeStringSeqOpt("");
    val expectedList = Seq[String]();
    assert(result === expectedList);

  }
}
