package io.bazel.rulesscala.dependencyanalyzer

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

  def decodeStringSeqOpt(targetsStr: String): Seq[String] = {
    //Lists of items are demlimited by ';' allowing for escaped ';' (since ; is valid in a bazel label)
   
    def extractAndAppendToken(tokens:List[String], str:String, startIdx:Int, endIdx:Int) : List[String] = {
      val token = str.substring(startIdx, endIdx).replace("\\", "")
      if(!token.isEmpty()){
        return tokens :+ token;
      }
      return tokens;
    }

    @annotation.tailrec
    def tokenize(tokens:List[String], targetsStr:String, currTokenStartIdx:Int, currIdx:Int, isEscaped:Boolean) : List[String] = {

      if(currIdx >= targetsStr.size)
        return tokens;

      val currChar = targetsStr.charAt(currIdx) 
            
      val isNextEscaped = if (!isEscaped)  (currChar == '\\') else  false;

      if(!isEscaped && currChar == ';'){
        val updatedTokens = extractAndAppendToken(tokens, targetsStr, currTokenStartIdx, currIdx);

        return tokenize(updatedTokens, targetsStr, currIdx + 1, currIdx + 1, isNextEscaped)
        
      }else if(currIdx == targetsStr.size-1){
        return extractAndAppendToken(tokens, targetsStr, currTokenStartIdx, targetsStr.size);
      }else{
        return tokenize(tokens, targetsStr, currTokenStartIdx, currIdx+1, isNextEscaped)
      }
    }

    tokenize(List[String](), targetsStr, 0, 0, false);    
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
        takeStringOpt(key).map(OptionsParser.decodeStringSeqOpt)
  }
}
