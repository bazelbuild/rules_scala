/*
 * Zinc - The incremental compiler for Scala.
 * Copyright 2011 - 2017, Lightbend, Inc.
 * Copyright 2008 - 2010, Mark Harrah
 * This software is released under the terms written in LICENSE.
 */

package third_party.plugin.src.main.io.bazel.rulesscala.dependencyanalyzer

import java.io.File

import scala.tools.nsc._
import scala.tools.nsc.io.AbstractFile

/** Defines the interface of the incremental compiler hiding implementation details. */
class CallbackGlobal(settings: Settings,
                                     reporter: reporters.Reporter)
    extends Global(settings, reporter) {

//  def callback: AnalysisCallback
//  def findClass(name: String): Option[(AbstractFile, Boolean)]

//  lazy val outputDirs: Iterable[File] = {
//    output match {
//      case single: SingleOutput => List(single.getOutputDirectory)
//      // Use Stream instead of List because Analyzer maps intensively over the directories
//      case multi: MultipleOutput => multi.getOutputGroups.toStream map (_.getOutputDirectory)
//    }
//  }

  /**
   * Defines the sbt phase in which the dependency analysis is performed.
   * The reason why this is exposed in the callback global is because it's used
   * in [[LocalToNonLocalClass]] to make sure the we don't resolve local
   * classes before we reach this phase.
   */
//  val sbtDependency: SubComponent

  /**
   * A map from local classes to non-local class that contains it.
   *
   * This map is used by both Dependency and Analyzer phase so it has to be
   * exposed here. The Analyzer phase uses the cached lookups performed by
   * the Dependency phase. By the time Analyzer phase is run (close to backend
   * phases), original owner chains are lost so Analyzer phase relies on
   * information saved before.
   *
   * The LocalToNonLocalClass duplicates the tracking that Scala compiler does
   * internally for backed purposes (generation of EnclosingClass attributes) but
   * that internal mapping doesn't have a stable interface we could rely on.
   */
  val localToNonLocalClass = new LocalToNonLocalClass[this.type](this)
}
