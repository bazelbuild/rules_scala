package pipeline;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import scala.reflect.io.PlainFile;

import java.io.File;
import java.io.IOException;
import java.util.jar.JarFile;
import java.util.jar.JarOutputStream;
import java.util.jar.Manifest;
import java.util.zip.ZipEntry;

import static org.junit.Assert.assertEquals;

public class FixedTimeJarFactoryTest {

    @Rule
    public TemporaryFolder temp = new TemporaryFolder();

    @Test
    public void overrideTimeOfEntry() throws IOException {
        File file = temp.newFile();

        try (JarOutputStream jar = jarOutputStream(file, new Manifest())) {
            ZipEntry entry = new ZipEntry("test");
            entry.setTime(1L);
            jar.putNextEntry(entry);
            jar.closeEntry();
            jar.flush();
        }

        try (JarFile jar = new JarFile(file)) {
            assertEquals(0L, jar.getEntry(JarFile.MANIFEST_NAME).getTime());
            assertEquals(0L, jar.getEntry("test").getTime());
        }
    }

    @Test
    public void writeGivenManifest() throws IOException {
        File file = temp.newFile();

        Manifest manifest = new Manifest();
        // Manifest-Version is required otherwise attributes are not written
        manifest.getMainAttributes().putValue("Manifest-Version", "1.0");
        manifest.getMainAttributes().putValue("test", "test");

        try (JarOutputStream jar = jarOutputStream(file, manifest)) {
            jar.flush();
        }

        try (JarFile jar = new JarFile(file)) {
            assertEquals("test", jar.getManifest().getMainAttributes().getValue("test"));
        }
    }

    private static JarOutputStream jarOutputStream(File file, Manifest manifest) {
        return new FixedTimeJarFactory().createJarOutputStream(
                PlainFile.getFile(file.getAbsolutePath()),
                manifest
        );
    }

}
