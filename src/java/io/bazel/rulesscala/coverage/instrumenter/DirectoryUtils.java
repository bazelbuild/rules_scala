package io.bazel.rulesscala.coverage.instrumenter;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;

public class DirectoryUtils {
    public static void deleteTempDir(Path tempDir) throws Exception {
        // Delete files in reverse order to ensure that nested directories are removed first.
        Files.walk(tempDir)
                .sorted(Comparator.reverseOrder())
                .map(Path::toFile)
                .forEach(File::delete);
    }
}
