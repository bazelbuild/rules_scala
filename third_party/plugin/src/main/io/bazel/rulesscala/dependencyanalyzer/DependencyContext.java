/**
 * This code is generated using [[http://www.scala-sbt.org/contraband/ sbt-contraband]].
 */

// DO NOT EDIT MANUALLY
package third_party.plugin.src.main.io.bazel.rulesscala.dependencyanalyzer;
/**
 * Enumeration of existing dependency contexts.
 * Dependency contexts represent the various kind of dependencies that
 * can exist between symbols.
 */
public enum DependencyContext {
    /**
     * Represents a direct dependency between two symbols :
     * object Foo
     * object Bar { def foo = Foo }
     */
    DependencyByMemberRef,
    /**
     * Represents an inheritance dependency between two symbols :
     * class A
     * class B extends A
     */
    DependencyByInheritance,
    /**
     * Represents an inheritance dependency between a local class
     * and a non local class:
     * // A.scala
     * class A
     * // B.scala
     * class B {
         * def foo = {
             * class Local extends A
             * }
             * }
             */
            LocalDependencyByInheritance;
            
        }
