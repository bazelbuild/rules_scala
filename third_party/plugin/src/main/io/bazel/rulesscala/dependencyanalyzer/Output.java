/*
 * Zinc - The incremental compiler for Scala.
 * Copyright 2011 - 2017, Lightbend, Inc.
 * Copyright 2008 - 2010, Mark Harrah
 * This software is released under the terms written in LICENSE.
 */

package third_party.plugin.src.main.io.bazel.rulesscala.dependencyanalyzer;

import java.io.File;
import java.io.Serializable;
import java.util.Optional;

/**
 * Define an abstract interface that represents the output of the compilation.
 * <p>
 * Inheritors are {@link SingleOutput} with a global output directory and
 * {@link MultipleOutput} that specifies the output directory per source file.
 * <p>
 * These two subclasses exist to satisfy the Scala compiler which accepts both
 * single and multiple targets. These targets may depend on the sources to be
 * compiled.
 * <p>
 * Note that Javac does not support multiple output and any attempt to use it
 * will result in a runtime exception.
 * <p>
 * This class is used both as an input to the compiler and as an output of the
 * {@link xsbti.compile.CompileAnalysis}.
 */
public interface Output extends Serializable {
    /**
     * Returns the multiple outputs passed or to be passed to the Scala compiler.
     * If single output directory is used or Javac will consume this setting,
     * it returns {@link Optional#EMPTY}.
     *
     * @see MultipleOutput
     */
    public Optional<OutputGroup[]> getMultipleOutput();

    /**
     * Returns the single output passed or to be passed to the Scala or Java compiler.
     * If multiple outputs are used, it returns {@link Optional#EMPTY}.
     *
     * @see SingleOutput
     */
    public Optional<File> getSingleOutput();
}
