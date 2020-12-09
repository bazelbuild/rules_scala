package pipeline;

import io.bazel.rulesscala.worker.Worker;
import scala.collection.Traversable;
import scala.reflect.io.*;
import scala.runtime.BoxedUnit;
import scala.tools.nsc.CompilerCommand;
import scala.tools.nsc.Global;
import scala.tools.nsc.Settings;

import java.io.File;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static scala.collection.JavaConverters.asJavaCollection;
import static scala.collection.JavaConverters.asScalaBuffer;

/*
    Currently this simple wraps nsc into worker.
    Maybe there is no need for it to be so generic
    Maybe it should be tailored for pickler.
    TODO: Fix reporting.
    TODO: Encapsulate pickler flags?
    TODO: Rename to Compiler or Scalac?
*/
public class Pickler implements Worker.Interface {

    public static void main(String... args) throws Exception {
        Worker.workerMain(args, new Pickler());
    }

    @Override
    public void work(String... args) {
        CompilerCommand command = new CompilerCommand(
                asScalaBuffer(Arrays.asList(args)).toList(),
                new Settings()
        );
        Global compiler = new Global(command.settings());
        Global.Run run = compiler.new Run();

        List<AbstractFile> files = new ArrayList<>(command.files().length());

        for (String filename : asJavaCollection(command.files())) {
            if (filename.endsWith(".srcjar")) {
                // TODO: Clean this up
                // TODO: This leaks resources as nothing closes zip files
                File file = Paths.get(filename).toFile();
                FileZipArchive zip = ZipArchive.fromFile(file);

                zip.allDirs().forEach((k, v) -> {
                    Traversable<ZipArchive.Entry> entryTraversable = v.entries().values().filter(f -> f.hasExtension("scala") || f.hasExtension("java"));
                    files.addAll(asJavaCollection(entryTraversable.toList()));
                });

            } else {
                files.add(PlainFile.getFile(filename));
            }
        }

        run.compileFiles(asScalaBuffer(files).toList());

        if (compiler.reporter().hasErrors()) {
            compiler.reporter().flush();
        }

    }
}
