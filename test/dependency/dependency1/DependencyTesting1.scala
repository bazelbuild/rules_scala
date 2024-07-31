package test.dependency.dependency1

import test.dependency.dependency2.DependencyTesting2
import test.dependency.dependency3.DependencyTesting3

class DependencyTesting1 {
  def x = new DependencyTesting3
}
