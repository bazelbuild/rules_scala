package io.bazel.rules_scala.discover_tests_worker

import io.bazel.rulesscala.worker.Worker
import io.bazel.rules_scala.discover_tests_worker.DiscoveredTests.Result
import io.bazel.rules_scala.discover_tests_worker.DiscoveredTests.FrameworkDiscovery
import io.bazel.rules_scala.discover_tests_worker.DiscoveredTests.AnnotatedDiscovery
import io.bazel.rules_scala.discover_tests_worker.DiscoveredTests.SubclassDiscovery

import io.github.classgraph.ClassGraph
import io.github.classgraph.ClassInfo
import io.github.classgraph.ClassInfoList
import io.github.classgraph.ScanResult

import sbt.testing.Framework
import sbt.testing.SubclassFingerprint
import sbt.testing.AnnotatedFingerprint

import java.io.FileOutputStream
import java.net.URLClassLoader
import java.nio.file.Paths

import scala.collection.JavaConverters._

/**
  * DiscoverTestsWorker is responsible for scanning jars to indentify
  * classes and modules that conform to the SBT testing interface.
  *
  * Identified tests are written to a protobuf output file so a separate
  * test runner can handle test execution.
  */
object DiscoverTestsWorker extends Worker.Interface {

  def main(args: Array[String]): Unit = Worker.workerMain(args, DiscoverTestsWorker)

  def work(args: Array[String]): Unit = {
    // argument format: <outputFile> <testJars>+ -- <frameworkJars>+
    val outputFile = Paths.get(args(0)).toFile
    val (args0, args1) = args.tail.span(_ != "--")
    val testJars = args0.map(f => Paths.get(f).toUri.toURL)
    val frameworkJars = args1.tail.map(f => Paths.get(f).toUri.toURL)

    // prep the scanner used to identify testing frameworks
    val frameworkClassloader = new URLClassLoader(frameworkJars)
    val frameworkScanResult: ScanResult = (new ClassGraph)
      .overrideClassLoaders(frameworkClassloader)
      .ignoreParentClassLoaders
      .enableClassInfo.scan

    // prep the scanner used to find tests
    // here we need the full classpath
    val testScanResult: ScanResult = (new ClassGraph)
      .overrideClassLoaders(new URLClassLoader(testJars ++ frameworkJars))
      .ignoreParentClassLoaders
      .enableClassInfo
      .enableMethodInfo
      .enableAnnotationInfo
      .scan

    val resultBuilder: Result.Builder = Result.newBuilder

    // start identifying frameworks and tests
    frameworkScanResult
      .getClassesImplementing("sbt.testing.Framework").asScala
      .foreach(handleFramework(frameworkScanResult, testScanResult, resultBuilder, _))

    val result: Result = resultBuilder.build

    testScanResult.close()
    frameworkScanResult.close()

    val os = new FileOutputStream(outputFile)
    result.writeTo(os)
    os.close()
  }

  private[this] def handleFramework(frameworkScanResult: ScanResult, testScanResult: ScanResult, builder: Result.Builder, framework: ClassInfo): Unit = {
    val frameworkInstance = framework.loadClass.newInstance.asInstanceOf[Framework]

    val frameworkDiscoveryBuilder = FrameworkDiscovery.newBuilder.setFramework(framework.getName)
    frameworkInstance.fingerprints.foreach {
      case sf: SubclassFingerprint => handleSubclassFingerprint(frameworkScanResult, testScanResult, frameworkDiscoveryBuilder, sf)
      case af: AnnotatedFingerprint => handleAnnotatedFingerprint(frameworkScanResult, testScanResult, frameworkDiscoveryBuilder, af)
    }
    builder.addFrameworkDiscoveries(frameworkDiscoveryBuilder.build)
  }

  private[this] def handleSubclassFingerprint(frameworkScanResult: ScanResult, testScanResult: ScanResult, builder: FrameworkDiscovery.Builder, fingerprint: SubclassFingerprint): Unit = {
    //
    // with the ClassGraph API we need to identify tests differently if they're implementing
    // an interface instead of a class
    //
    // this logic is captured as a function so we can call it a few times
    val getCandidates: ScanResult => ClassInfoList =
      if (frameworkScanResult.getClassInfo(fingerprint.superclassName).isInterface)
        _.getClassesImplementing(fingerprint.superclassName)
      else
        _.getSubclasses(fingerprint.superclassName)

    val candidates: Iterable[ClassInfo] =
      getCandidates(testScanResult)
        .exclude(getCandidates(frameworkScanResult))
        .asScala
        .filter(_.isStandardClass)

    val tests: Iterable[String] =
      if (fingerprint.isModule)
        candidates
          .map(_.getName)
          .filter(_.endsWith("$")).map(_.dropRight(1))
      else
        candidates
          .filter(_.getConstructorInfo.asScala.exists(_.getParameterInfo.isEmpty) == fingerprint.requireNoArgConstructor)
          .map(_.getName)
          .filterNot(_.endsWith("$"))

    builder.addSubclassDiscoveries(
      SubclassDiscovery.newBuilder
        .setSuperclassName(fingerprint.superclassName)
        .setIsModule(fingerprint.isModule)
        .setRequireNoArgConstructor(fingerprint.requireNoArgConstructor)
        .addAllTests(tests.asJava)
        .build)
  }

  private[this] def handleAnnotatedFingerprint(frameworkScanResult: ScanResult, testScanResult: ScanResult, builder: FrameworkDiscovery.Builder, fingerprint: AnnotatedFingerprint): Unit = {
    val candidates: Iterable[ClassInfo] =
      testScanResult.getClassesWithAnnotation(fingerprint.annotationName)
        .union(testScanResult.getClassesWithMethodAnnotation(fingerprint.annotationName))
        .asScala

    // note: "$" is part of Scala's JVM encoding for modules
    val tests: Iterable[String] =
      if (fingerprint.isModule)
        candidates
          .map(_.getName)
          .filter(_.endsWith("$")).map(_.dropRight(1))
      else
        candidates
          .map(_.getName)
          .filterNot(_.endsWith("$"))

    builder.addAnnotatedDiscoveries(
      AnnotatedDiscovery.newBuilder
        .setAnnotationName(fingerprint.annotationName)
        .setIsModule(fingerprint.isModule)
        .addAllTests(tests.asJava)
        .build)
  }
}
