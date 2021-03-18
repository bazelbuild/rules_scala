package io.bazel.rulesscala.dependencyanalyzer

import java.nio.file.Files
import java.nio.file.Path
import io.bazel.rulesscala.io_utils.DeleteRecursively
import org.scalatest.funsuite._
import scala.tools.nsc.reporters.StoreReporter
import io.bazel.rulesscala.utils.JavaCompileUtil
import io.bazel.rulesscala.utils.TestUtil
import io.bazel.rulesscala.utils.TestUtil.DependencyAnalyzerTestParams

// NOTE: Some tests are version-dependent as some false positives
// cannot be fixed in older versions of Scala for various reasons.
// Hence make sure to look at any version checks to understand
// which versions do and don't support which cases.
class AstUsedJarFinderTest extends AnyFunSuite {
  private def withSandbox(action: Sandbox => Unit): Unit = {
    val tmpDir = Files.createTempDirectory("dependency_analyzer_test_temp")
    try {
      action(new Sandbox(tmpDir))
    } finally {
      DeleteRecursively.run(tmpDir)
    }
  }

  private class Sandbox(tmpDir: Path) {
    def compileWithoutAnalyzer(
      code: String
    ): Unit = {
      val errors =
        TestUtil.runCompiler(
          code = code,
          extraClasspath = List(tmpDir.toString),
          outputPathOpt = Some(tmpDir)
        )
      assert(errors.isEmpty)
    }

    def compileJava(
      className: String,
      code: String
    ): Unit = {
      JavaCompileUtil.compile(
        tmpDir = tmpDir.toString,
        className = className,
        code = code
      )
    }

    private def verifyAndConvertDepToClass(dep: String): String = {
      val classPath = tmpDir.resolve(s"$dep.class")
      // Make sure the dep refers to a real file
      assert(classPath.toFile.isFile)
      classPath.toString
    }

    def checkStrictDepsErrorsReported(
      code: String,
      expectedStrictDeps: List[String]
    ): List[StoreReporter#Info] = {
      val errors =
        TestUtil.runCompiler(
          code = code,
          extraClasspath = List(tmpDir.toString),
          dependencyAnalyzerParamsOpt =
            Some(
              DependencyAnalyzerTestParams(
                indirectJars = expectedStrictDeps.map(verifyAndConvertDepToClass),
                indirectTargets = expectedStrictDeps,
                strictDeps = true,
                dependencyTrackingMethod = DependencyTrackingMethod.Ast
              )
            )
        )

      assert(errors.size == expectedStrictDeps.size)
      errors.foreach { err =>
        // We should be emitting errors with positions
        assert(err.pos.isDefined)
      }

      expectedStrictDeps.foreach { dep =>
        val expectedError = s"Target '$dep' is used but isn't explicitly declared, please add it to the deps"
        assert(errors.exists(_.msg.contains(expectedError)))
      }

      errors
    }

    def checkUnusedDepsErrorReported(
      code: String,
      expectedUnusedDeps: List[String]
    ): Unit = {
      val errors =
        TestUtil.runCompiler(
          code = code,
          extraClasspath = List(tmpDir.toString),
          dependencyAnalyzerParamsOpt =
            Some(
              DependencyAnalyzerTestParams(
                directJars = expectedUnusedDeps.map(verifyAndConvertDepToClass),
                directTargets = expectedUnusedDeps,
                unusedDeps = true,
                dependencyTrackingMethod = DependencyTrackingMethod.Ast
              )
            )
        )

      assert(errors.size == expectedUnusedDeps.size)
      errors.foreach { err =>
        // As an unused dep we shouldn't include a position or anything like that
        assert(!err.pos.isDefined)
      }

      expectedUnusedDeps.foreach { dep =>
        val expectedError = s"Target '$dep' is specified as a dependency to ${TestUtil.defaultTarget} but isn't used, please remove it from the deps."
        assert(errors.exists(_.msg.contains(expectedError)))
      }
    }
  }

  /**
   * In a situation where B depends on A directly, ensure that the
   * dependency analyzer recognizes this fact.
   */
  private def checkDirectDependencyRecognized(
    aCode: String,
    bCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.checkStrictDepsErrorsReported(
        code = bCode,
        expectedStrictDeps = List("A")
      )
    }
  }

  /**
   * In a situation where C depends on both A and B directly, ensure
   * that the dependency analyzer recognizes this fact.
   */
  private def checkDirectDependencyRecognized(
    aCode: String,
    bCode: String,
    cCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.compileWithoutAnalyzer(bCode)
      sandbox.checkStrictDepsErrorsReported(
        code = cCode,
        expectedStrictDeps = List("A", "B")
      )
    }
  }

  /**
   * In a situation where C depends directly on B but not on A, ensure
   * that the dependency analyzer recognizes this fact.
   */
  private def checkIndirectDependencyDetected(
    aCode: String,
    bCode: String,
    cCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.compileWithoutAnalyzer(bCode)
      sandbox.checkUnusedDepsErrorReported(
        code = cCode,
        expectedUnusedDeps = List("A")
      )
    }
  }

  /**
   * In a situation where B depends indirectly on A, ensure
   * that the dependency analyzer recognizes this fact.
   */
  private def checkIndirectDependencyDetected(
    aCode: String,
    bCode: String
  ): Unit = {
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer(aCode)
      sandbox.checkUnusedDepsErrorReported(
        code = bCode,
        expectedUnusedDeps = List("A")
      )
    }
  }

  test("simple composition in indirect") {
    checkIndirectDependencyDetected(
      aCode =
        """
          |class A
          |""".stripMargin,
      bCode =
        """
          |class B(a: A)
          |""".stripMargin,
      cCode =
        """
          |class C(b: B)
          |""".stripMargin
    )
  }

  test("method call argument is direct") {
    checkDirectDependencyRecognized(
      aCode =
        """
          |class A
          |""".stripMargin,
      bCode =
        """
          |class B {
          |  def foo(a: A = new A()): Unit = {}
          |}
          |""".stripMargin,
      cCode =
        """
          |class C {
          |  def bar(): Unit = {
          |    new B().foo(new A())
          |  }
          |}
          |""".stripMargin
    )
  }

  test("class ctor arg type parameter is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B(
           |  a: Option[A]
           |)
           |""".stripMargin
    )
  }

  test("class static annotation is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |) extends scala.annotation.StaticAnnotation
           |""".stripMargin,
      bCode =
        s"""
           |@A
           |class B(
           |)
           |""".stripMargin
    )
  }

  test("class annotation is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |) extends scala.annotation.Annotation
           |""".stripMargin,
      bCode =
        s"""
           |@A
           |class B(
           |)
           |""".stripMargin
    )
  }

  test("method annotation is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |) extends scala.annotation.Annotation
           |""".stripMargin,
      bCode =
        s"""
           |class B {
           |  @A
           |  def foo(): Unit = {
           |  }
           |}
           |""".stripMargin
    )
  }

  test("static annotation of inherited class is indirect") {
    checkIndirectDependencyDetected(
      aCode = "class A extends scala.annotation.StaticAnnotation",
      bCode = "@A class B",
      cCode = "class C extends B"
    )
  }

  test("class type parameter bound is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B[T <: A](
           |)
           |""".stripMargin
    )
  }

  test("classOf is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |class A(
           |)
           |""".stripMargin,
      bCode =
        s"""
           |class B(
           |) {
           |  val x: Class[_] = classOf[A]
           |}
           |""".stripMargin
    )
  }

  test("classOf in class annotation is direct") {
    checkDirectDependencyRecognized(
      aCode = "class A",
      bCode = "class B(a: Any) extends scala.annotation.Annotation",
      cCode =
        s"""
           |@B(classOf[A])
           |class C
           |""".stripMargin
    )
  }

  test("inlined literal is direct") {
    // Note: For a constant to be inlined
    // - it must not have a type declaration such as `: Int`.
    //   (this appears to be the case in practice at least)
    //   (is this documented anywhere???)
    // - some claim it must start with a capital letter, though
    //   this does not seem to be the case. Nevertheless we do that
    //    anyways.
    //
    // Hence it is possible that as newer versions of scala
    // are released then this test may need to be updated to
    // conform to changing requirements of what is inlined.

    // Note that in versions of scala < 2.12.4 we cannot detect
    // such a situation. Hence we will have a false positive here
    // for those older versions, which we verify in test.

    val aCode =
      s"""
         |object A {
         |  final val Inlined = 123
         |}
         |""".stripMargin
    val bCode =
      s"""
         |object B {
         |  val d: Int = A.Inlined
         |}
         |""".stripMargin

    if (ScalaVersion.Current >= ScalaVersion("2.12.4")) {
      checkDirectDependencyRecognized(aCode = aCode, bCode = bCode)
    } else {
      checkIndirectDependencyDetected(aCode = aCode, bCode = bCode)
    }
  }

  test("unspecified default argument type is indirect") {
    checkIndirectDependencyDetected(
      aCode = "class A",
      bCode = "class B(a: A = new A())",
      cCode =
        s"""
           |class C {
           |  new B()
           |}
           |""".stripMargin
    )
  }

  test("macro is direct") {
    checkDirectDependencyRecognized(
      aCode =
        s"""
           |import scala.language.experimental.macros
           |import scala.reflect.macros.blackbox.Context
           |
           |object A {
           |  def foo(): Unit = macro fooImpl
           |  def fooImpl(
           |    c: Context
           |  )(): c.universe.Tree = {
           |    import c.universe._
           |    q""
           |  }
           |}
           |""".stripMargin,
      bCode =
        s"""
           |object B {
           |  A.foo()
           |}
           |""".stripMargin
    )
  }

  test("imports are complicated") {
    // This test documents the behavior of imports as is currently.
    // Ideally all imports would be direct dependencies. However there
    // are complications. The main one being that the scala AST treats
    // imports as (expr, selectors) where in e.g. `import a.b.{c, d}`
    // expr=`a.b` and selectors=[c, d]. (Note selectors are always formed
    // from the last part of the import).
    // And only the expr part has type information attached. In order
    // to gather type information from the selector, we would need to
    // do some resolution of types, which is possible but probably complex.
    // Note also that fixing this is probably less of a priority, as
    // people who want to check unused deps generally also want to check
    // unused imports, so they wouldn't run into these problems in the
    // first place.

    def testImport(importString: String, isDirect: Boolean): Unit = {
      withSandbox { sandbox =>
        sandbox.compileWithoutAnalyzer(
          s"""
             |package foo.bar
             |
             |object A { val i: Int = 0 }
             |""".stripMargin
        )

        val bCode =
          s"""
             |import $importString
             |
             |class B
             |""".stripMargin
        val dep = "foo/bar/A"

        if (isDirect) {
          sandbox.checkStrictDepsErrorsReported(
            code = bCode,
            expectedStrictDeps = List(dep)
          )
        } else {
          sandbox.checkUnusedDepsErrorReported(
            code = bCode,
            expectedUnusedDeps = List(dep)
          )
        }
      }
    }

    // In this case, expr=foo.bar.A and selectors=[i], so looking at expr does
    // give us a type.
    testImport("foo.bar.A.i", isDirect = true)

    // In this case expr=foo.bar and selectors=[A], so expr does not have
    // a type which corresponds with A.
    testImport("foo.bar.A", isDirect = false)

    // In this case expr=foo and selectors=[bar], so expr does not have
    // a type which corresponds with A.
    testImport("foo.bar", isDirect = false)

    // In this case expr=foo.bar and selectors=[_], so expr does not have
    // a type which corresponds with A.
    testImport("foo.bar._", isDirect = false)
  }

  test("java interface method argument is direct") {
    withSandbox { sandbox =>
      sandbox.compileJava(
        className = "B",
        code = "public interface B { }"
      )
      sandbox.checkStrictDepsErrorsReported(
        """
          |class C {
          |  def foo(x: B): Unit = {}
          |}
          |""".stripMargin,
        expectedStrictDeps = List("B")
      )
    }
  }

  test("java interface field and method is direct") {
    withSandbox { sandbox =>
      sandbox.compileJava(
        className = "A",
        code = "public interface A { int a = 42; }"
      )
      val bCode =
        """
          |class B {
          |  def foo(x: A): Unit = {}
          |  val b = A.a
          |}
          |""".stripMargin

      // Unlike other tests, this one includes both access to an inlined
      // variable and taking the class A as an argument. In theory,
      // this test should work for all supported versions just like
      // test `java interface method argument is direct` since they
      // both have a method taking A as an argument.
      //
      // However, it does not work for all versions. It is unclear why but
      // presumably there were various compiler improvements.
      if (ScalaVersion.Current >= ScalaVersion("2.12.0")) {
        sandbox.checkStrictDepsErrorsReported(
          bCode,
          expectedStrictDeps = List("A")
        )
      } else {
        sandbox.checkUnusedDepsErrorReported(
          bCode,
          expectedUnusedDeps = List("A")
        )
      }
    }
  }

  test("java interface field is direct") {
    withSandbox { sandbox =>
      sandbox.compileJava(
        className = "A",
        code = "public interface A { int a = 42; }"
      )
      val bCode =
        """
          |class B {
          |  val b = A.a
          |}
          |""".stripMargin
      if (ScalaVersion.Current >= ScalaVersion("2.12.4")) {
        sandbox.checkStrictDepsErrorsReported(
          bCode,
          expectedStrictDeps = List("A")
        )
      } else {
        sandbox.checkUnusedDepsErrorReported(
          bCode,
          expectedUnusedDeps = List("A")
        )
      }
    }
  }

  test("classOf in class Java annotation is direct") {
    withSandbox { sandbox =>
      sandbox.compileJava(
        className = "Category",
        code =
          s"""
             |public @interface Category {
             |    Class<?> value();
             |}
             |""".stripMargin
      )
      sandbox.compileWithoutAnalyzer("class UnitTests")
      sandbox.checkStrictDepsErrorsReported(
        """
          |@Category(classOf[UnitTests])
          |class C
          |""".stripMargin,
        expectedStrictDeps = List("UnitTests", "Category")
      )
    }
  }

  test("position of strict deps error is correct") {
    // While we do ensure that generally strict deps errors have
    // a position in the other tests, here we make sure that that
    // position is correctly computed.
    withSandbox { sandbox =>
      sandbox.compileWithoutAnalyzer("class A")
      val errors =
        sandbox.checkStrictDepsErrorsReported(
          "class B(a: A)",
          expectedStrictDeps = List("A")
        )
      assert(errors.size == 1)
      val pos = errors(0).pos
      assert(pos.line == 1)
      assert(pos.column == 12)
    }
  }
}
