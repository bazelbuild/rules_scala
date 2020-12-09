package pipeline;

import scala.reflect.io.AbstractFile;
import scala.tools.nsc.util.JarFactory;

import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.jar.JarOutputStream;
import java.util.jar.Manifest;
import java.util.zip.ZipEntry;

public final class FixedTimeJarFactory implements JarFactory {

    private static final int BUFFER_SIZE = 64000; // Taken from scala.tools.nsc.util.DefaultJarFactory

    @Override
    public JarOutputStream createJarOutputStream(AbstractFile file, Manifest manifest) {
        try {
            OutputStream out = new BufferedOutputStream(new FileOutputStream(file.file()), BUFFER_SIZE);
            return new JarOutputStream(out, manifest) {
                @Override
                public void putNextEntry(ZipEntry e) throws IOException {
                    e.setTime(0L);
                    super.putNextEntry(e);
                }
            };
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
    }
}
