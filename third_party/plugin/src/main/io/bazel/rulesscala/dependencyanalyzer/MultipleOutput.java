/*
 * Zinc - The incremental compiler for Scala.
 * Copyright 2011 - 2017, Lightbend, Inc.
 * Copyright 2008 - 2010, Mark Harrah
 * This software is released under the terms written in LICENSE.
 */

package third_party.plugin.src.main.io.bazel.rulesscala.dependencyanalyzer;

import java.io.File;
import java.util.Optional;

/**
 * Represents a mapping of several outputs depending on the source directory.
 * <p>
 * This option is used only by the Scala compiler.
 */
public interface MultipleOutput extends Output {
    /**
     * Return an array of the existent output groups.
     * <p>
     * Incremental compilation manages the class files in these directories, so
     * don't play with them out of the Zinc API. Zinc already takes care of
     * deleting classes before every compilation run.
     */
    public OutputGroup[] getOutputGroups();

    @Override
    public default Optional<File> getSingleOutput() {
        return Optional.empty();
    }

    @Override
    public default Optional<OutputGroup[]> getMultipleOutput() {
        return Optional.of(getOutputGroups());
    }
}