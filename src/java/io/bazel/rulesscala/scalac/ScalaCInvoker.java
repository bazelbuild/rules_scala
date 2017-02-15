// Copyright 2014 The Bazel Authors. All rights reserved.
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

package io.bazel.rulesscala.scalac;

import java.io.PrintStream;
import io.bazel.rulesscala.worker.GenericWorker;
import io.bazel.rulesscala.worker.Processor;
import scala.Console$;

/**
 * This is our entry point to producing a scala target
 * this can act as one of Bazel's persistant workers.
 */
public class ScalaCInvoker extends GenericWorker {
  public ScalaCInvoker() {
    super(new ScalacProcessor());
  }

  @Override protected void setupOutput(PrintStream ps) {
    System.setOut(ps);
    System.setErr(ps);
    Console$.MODULE$.setErrDirect(ps);
    Console$.MODULE$.setOutDirect(ps);
  }


  public static void main(String[] args) {
    try {
      GenericWorker w = new ScalaCInvoker();
      w.run(args);
    }
    catch (Exception ex) {
      ex.printStackTrace();
      System.exit(1);
    }
  }
}
