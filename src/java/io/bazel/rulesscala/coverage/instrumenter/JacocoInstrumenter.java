package io.bazel.rulesscala.coverage.instrumenter;

import io.bazel.rulesscala.jar.JarCreator;
import io.bazel.rulesscala.worker.Worker;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.FileSystem;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitor;
import java.nio.file.FileVisitResult;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Collections;
import java.util.List;
import java.util.function.Consumer;
import java.util.function.Function;

import org.jacoco.core.instr.Instrumenter;
import org.jacoco.core.runtime.OfflineInstrumentationAccessGenerator;

public final class JacocoInstrumenter implements Worker.Interface {

    public static void main(String[] args) throws Exception {
	Worker.workerMain(args, new JacocoInstrumenter());
    }

    @Override
    public void work(String[] args) throws Exception {
        Instrumenter jacoco = new Instrumenter(new OfflineInstrumentationAccessGenerator());
        for (String arg : args) {
            processArg(jacoco, arg);
	}
    }

    private void processArg(Instrumenter jacoco, String arg) throws Exception {
        String[] parts = arg.split("=");
        if (parts.length != 3) {
            throw new Exception("expected `in_path=out_path=srcs` form for argument: " + arg);	
        }
        Path inPath = Paths.get(parts[0]);
        Path outPath = Paths.get(parts[1]);
        String srcs = parts[2];
        try (
            FileSystem inFS = FileSystems.newFileSystem(inPath, null); FileSystem outFS = FileSystems.newFileSystem(
                URI.create("jar:" + outPath.toUri()), Collections.singletonMap("create", "true"));
        ) {
            FileVisitor fileVisitor = createInstrumenterVisitor(jacoco, outFS);
            inFS.getRootDirectories().forEach(root -> {
                try {
                    Files.walkFileTree(root, fileVisitor);
                } catch (final Exception e) {
                    throw new RuntimeException(e);
                }
            });

            /* 
            * https://github.com/bazelbuild/bazel/blob/567ca633d016572f5760bfd027c10616f2b8c2e4/src/java_tools/junitrunner/java/com/google/testing/coverage/JacocoCoverageRunner.java#L411
            * 
            * Bazel / JacocoCoverageRunner will look for any file that ends with '-paths-for-coverage.txt' within the JAR to be later used for reconstructing the path for source files.
            * This is a fairly undocumented feature within bazel at this time, but in essence, it opens all the jars, searches for all files matching '-paths-for-coverage.txt'
            * and then adds them to a single in memory set. 
            * 
            * https://github.com/bazelbuild/bazel/blob/567ca633d016572f5760bfd027c10616f2b8c2e4/src/java_tools/junitrunner/java/com/google/testing/coverage/JacocoLCOVFormatter.java#L70
            * Which is then used in the formatter to find the corresponding source file from the set of sources we wrote in all the JARs.
            */
            Files.write(
                outFS.getPath("-paths-for-coverage.txt"),
                srcs.replace(",", "\n").getBytes(java.nio.charset.StandardCharsets.UTF_8)
            );
        }
    }

    private SimpleFileVisitor createInstrumenterVisitor(Instrumenter jacoco, FileSystem outFS) {
        return new SimpleFileVisitor <Path> () {
            @Override
            public FileVisitResult visitFile(Path inPath, BasicFileAttributes attrs) {
                try {
                    return actuallyVisitFile(inPath, attrs);
                } catch (final Exception e) {
                    throw new RuntimeException(e);
                }
            }

            private FileVisitResult actuallyVisitFile(Path inPath, BasicFileAttributes attrs) throws Exception {
                Path outPath = outFS.getPath(inPath.toString());
                Files.createDirectories(outPath.getParent());
                if (inPath.toString().endsWith(".class")) {
                    try (
                        BufferedInputStream inStream = new BufferedInputStream(
                            Files.newInputStream(inPath)); BufferedOutputStream outStream = new BufferedOutputStream(
                            Files.newOutputStream(outPath, StandardOpenOption.CREATE_NEW));
                    ) {
                        jacoco.instrument(inStream, outStream, inPath.toString());
                    }
                    Files.copy(inPath, outFS.getPath(outPath.toString() + ".uninstrumented"));
                } else {
                    Files.copy(inPath, outPath);
                }
                return FileVisitResult.CONTINUE;
            }
        };
    }
}
