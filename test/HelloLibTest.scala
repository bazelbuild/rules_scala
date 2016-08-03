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

import org.scalatest._

object TestUtil {
  def foo: String = "bar"
}

class ScalaSuite extends FlatSpec {
  "HelloLib" should "call scala" in {
    assert(HelloLib.getOtherLibMessage("hello").equals("hello you all, everybody. I am Runtime"))
  }
}

class JavaSuite extends FlatSpec {
  "HelloLib" should "call java" in {
    assert(HelloLib.getOtherJavaLibMessage("hello").equals("hello java!"))
  }
}
