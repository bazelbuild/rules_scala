package pipeline;

import scala.Function1;
import scala.collection.immutable.List;
import scala.reflect.io.AbstractFile;
import scala.runtime.BoxedUnit;
import scala.tools.nsc.Global;
import scala.tools.nsc.plugins.Plugin;
import scala.tools.nsc.plugins.PluginComponent;

import java.util.HashMap;
import java.util.Map;
import java.util.jar.Attributes;
import java.util.jar.Manifest;

import static scala.collection.JavaConverters.asJavaCollection;

// TODO: Rename
public class ManifestMod extends Plugin {

    private final Global global;
    private Map<String, String> entries = new HashMap<>();

    public ManifestMod(Global global) {
        this.global = global;
    }

    @Override
    public boolean init(List<String> options, Function1<String, BoxedUnit> error) {
        asJavaCollection(options).forEach(e -> {
            // TODO: Cleanup
            String[] x = e.split("=");
            entries.put(x[0], x[1]);
        });
        return true;
    }

    @Override
    public void augmentManifest(AbstractFile file, Manifest manifest) {
        Attributes attributes = manifest.getMainAttributes();
        entries.forEach(attributes::putValue);
    }

    @Override
    public String name() {
        return "ManifestMod";
    }

    @Override
    public List<PluginComponent> components() {
        return scala.collection.immutable.List.empty();
    }

    @Override
    public String description() {
        return "ManifestMod";
    }

    @Override
    public Global global() {
        return global;
    }

}
