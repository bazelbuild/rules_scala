package scalarules.test.scala_import.nl;

/**
 * This class is packaged in scala_import_never_link.jar
 *
 * The jar file was created with the following steps:
 *
 * - javac ScalaImportNeverLink.java
 * - makdir -p scalarules/test/scala_import/nl
 * - mv ScalaImportNeverLink.class scalarules/test/scala_import/nl
 * - jar cf scala_import_never_link.jar scalarules
 * - rm -fr scalarules ScalaImportNeverLink.class
 *
 * To stage the updated jar: git add -f scala_import_never_link.jar
 */
public class ScalaImportNeverLink {
}
