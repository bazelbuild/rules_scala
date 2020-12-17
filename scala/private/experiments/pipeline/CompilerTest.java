package pipeline;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.jar.JarFile;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import static java.util.Arrays.asList;
import static java.util.jar.JarFile.MANIFEST_NAME;
import static java.util.stream.Collectors.toList;
import static org.junit.Assert.assertEquals;

public class CompilerTest {

    @Rule
    public TemporaryFolder temp = new TemporaryFolder();

    @Test
    public void compileScalaSourceFileIntoJar() throws Exception {
        File out = temp.newFile("out.jar");

        File src = temp.newFile("src.scala");

        Files.write(src.toPath(), "package test { class Test }".getBytes());

        pipeline.Compiler.main("-usejavacp", "-d", out.getAbsolutePath(), src.getAbsolutePath());

        assertEntries(out, "test/Test.class");
    }

    @Test
    public void overrideOutputJarOfPreviousCompilation() throws Exception {
        File out = temp.newFile("out.jar");

        File src = temp.newFile("src.scala");

        Files.write(src.toPath(), "package test { class A }".getBytes());

        pipeline.Compiler.main("-usejavacp", "-d", out.getAbsolutePath(), src.getAbsolutePath());

        assertEntries(out, "test/A.class");

        Files.write(src.toPath(), "package test { class B }".getBytes());

        pipeline.Compiler.main("-usejavacp", "-d", out.getAbsolutePath(), src.getAbsolutePath());

        assertEntries(out, "test/B.class");
    }

    @Test
    public void acceptSrcJarAsInputSources() throws Exception {
        File out = temp.newFile("out.jar");

        File src = temp.newFile("test.srcjar");

        try (ZipOutputStream jar = new ZipOutputStream(new FileOutputStream(src))) {
            jar.putNextEntry(new ZipEntry("test/"));
            jar.putNextEntry(new ZipEntry("test/A.scala"));
            jar.write("package test { class A }".getBytes());
            jar.closeEntry();
            jar.flush();
        }

        pipeline.Compiler.main("-usejavacp", "-d", out.getAbsolutePath(), src.getAbsolutePath());

        assertEntries(out, "test/A.class");
    }

    @Test
    public void generateSigJarForScalaSourceFile() throws Exception {
        File out = temp.newFile("out.jar");

        File src = temp.newFile("src.scala");

        Files.write(src.toPath(), "package test { class Test }".getBytes());

        pipeline.Compiler.main(
                "-usejavacp",
                "-Youtline",
                "-Ystop-after:pickler",
                "-Ymacro-expand:none",
                "-Ypickle-write-api-only",
                "-Ypickle-write", out.getAbsolutePath(),
                src.getAbsolutePath()
        );

        assertEntries(out, "test/Test.sig");
    }

    private static void assertEntries(File file, String... expectedEntries) throws IOException {
        try (JarFile jar = new JarFile(file)) {
            assertEquals(asList(expectedEntries), jar.stream()
                    .map(ZipEntry::getName)
                    .filter(e -> !e.equals(MANIFEST_NAME))
                    .collect(toList())
            );
        }
    }

}
