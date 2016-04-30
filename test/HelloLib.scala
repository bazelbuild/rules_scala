// Copyright 2016 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package scala.test

object HelloLib {
  // This is to check the linter, which will recommend changing this
  // to just def dumb(x: Int) = x == 3
  def dumb(x: Int) = if (x == 3) true else false

  def printMessage(arg: String) {
    MacroTest.hello(arg == "yo")
    println(getOtherLibMessage(arg))
    println(getOtherJavaLibMessage(arg))
    println(Exported.message)
  }


  def getOtherLibMessage(arg: String) : String = {
    arg + " " + OtherLib.getMessage()
  }

  def getOtherJavaLibMessage(arg: String) : String = {
    arg + " " + OtherJavaLib.getMessage()
  }
}

