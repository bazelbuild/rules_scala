/*
 * Zinc - The incremental compiler for Scala.
 * Copyright 2011 - 2017, Lightbend, Inc.
 * Copyright 2008 - 2010, Mark Harrah
 * This software is released under the terms written in LICENSE.
 */

package third_party.plugin.src.main.io.bazel.rulesscala.dependencyanalyzer;

/**
 * Defines the scope in which a name hash was captured.
 *
 * The incremental compiler uses [[UseScope]] to determine some Scala semantics
 * assumed in the presence of a name in a concrete position. For instance,
 * [[PatMatTarget]] is used for names that appear as the target types of a
 * pattern match.
 *
 * The order of declaration of these is crucial. Don't change it.
 * Don't add more than 6 scopes. Otherwise, change `Mapper` implementation.
 */
public enum UseScope {
    /** Represent standard definition/usage. Default is present for each declaration and usage of given name. */
    Default,
    /** Used to track changes in implicit definition.
     * So far classes don't depend on this scope since implicit changes has it's own invalidation process */
    Implicit,
    /** Used in optimized sealed class invalidation (when IncOptions.seOptimizedSealed is true).
     * Only sealed classes/trait produce hash in this scope (for their names).
     * Class have dependencies in PatMatTarget scope to all names used in type of pattern match target. */
    PatMatTarget
}

