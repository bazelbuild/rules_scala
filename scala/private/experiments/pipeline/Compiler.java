package pipeline;

import io.bazel.rulesscala.worker.Worker;
import scala.Function1;
import scala.collection.Traversable;
import scala.reflect.io.AbstractFile;
import scala.reflect.io.FileZipArchive;
import scala.reflect.io.PlainFile;
import scala.reflect.io.ZipArchive;
import scala.tools.nsc.CompilerCommand;
import scala.tools.nsc.Global;

import java.io.File;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import static java.util.Arrays.asList;
import static scala.collection.JavaConverters.asJavaCollection;
import static scala.collection.JavaConverters.asScalaBuffer;
import static scala.runtime.BoxedUnit.UNIT;

public final class Compiler implements Worker.Interface {

    public static void main(String... args) throws Exception {
        Worker.workerMain(args, new pipeline.Compiler());
    }

    @Override
    public void work(String... args) {
        CompilerCommand command = parse(args);

        Global compiler = new Global(command.settings());
        Global.Run run = compiler.new Run();

        run.compileFiles(files(command));

        if (compiler.reporter().hasErrors()) {
            compiler.reporter().flush();
        }
    }

    private static CompilerCommand parse(String... args) {
        return new CompilerCommand(
                asScalaBuffer(asList(args)).toList(),
                error -> {
                    System.err.println(error);
                    return UNIT;
                }
        );
    }

    private static scala.collection.immutable.List<AbstractFile> files(CompilerCommand command) {
        List<AbstractFile> files = new ArrayList<>(command.files().length());
        for (String filename : asJavaCollection(command.files())) {
            if (filename.endsWith(".srcjar")) {
                files.addAll(extract(filename));
            } else {
                files.add(PlainFile.getFile(filename));
            }
        }
        return asScalaBuffer(files).toList();
    }

    private static List<AbstractFile> extract(String srcjar) {
        List<AbstractFile> files = new ArrayList<>();
        // TODO: Clean this up
        // TODO: This leaks resources as nothing closes zip files
        File file = Paths.get(srcjar).toFile();
        FileZipArchive zip = ZipArchive.fromFile(file);

        zip.allDirs().forEach((k, v) -> {
            Function1<ZipArchive.Entry, Object> sources = f -> f.hasExtension("scala") || f.hasExtension("java");
            Traversable<ZipArchive.Entry> entryTraversable = v.entries().values().filter(sources);
            files.addAll(asJavaCollection(entryTraversable.toList()));
        });

        return files;
    }

}
