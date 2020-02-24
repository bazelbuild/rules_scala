package io.bazel.rulesscala.coverage.instrumenter;

import io.bazel.rulesscala.jar.JarCreator;
import io.bazel.rulesscala.worker.GenericWorker;
import io.bazel.rulesscala.worker.Processor;

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

public final class JacocoInstrumenter implements Processor {

    public static void main(String[] args) throws Exception {
        (new Worker()).run(args);
    }

    private static final class Worker extends GenericWorker {
        public Worker() {
            super(new JacocoInstrumenter());
        }
    }

    @Override
    public void processRequest(List < String > args) {
        Instrumenter jacoco = new Instrumenter(new OfflineInstrumentationAccessGenerator());
        args.forEach(arg -> {
            try {
                processArg(jacoco, arg);
            } catch (final Exception e) {
                throw new RuntimeException(e);
            }
        });
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
            FileVisitor fileVisitor = createInstrumenterVisitor(jacoco, outFS, srcs);
            inFS.getRootDirectories().forEach(root -> {
                try {
                    Files.walkFileTree(root, fileVisitor);
                } catch (final Exception e) {
                    throw new RuntimeException(e);
                }
            });

            Files.write(
                outFS.getPath("-paths-for-coverage.txt"),
                srcs.replace(",", "\n").getBytes(java.nio.charset.StandardCharsets.UTF_8)
            );
        }
    }

    private SimpleFileVisitor createInstrumenterVisitor(Instrumenter jacoco, FileSystem outFS, String srcs) {
        return new SimpleFileVisitor <Path> () {
            @Override
            public FileVisitResult visitFile(Path inPath, BasicFileAttributes attrs) {
                try {
                    return actuallyVisitFile(inPath, attrs, srcs);
                } catch (final Exception e) {
                    throw new RuntimeException(e);
                }
            }

            private FileVisitResult actuallyVisitFile(Path inPath, BasicFileAttributes attrs, String srcs) throws Exception {
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
