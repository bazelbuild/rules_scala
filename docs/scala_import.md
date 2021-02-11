# scala_import

```starlark
scala_import(
    name,
    jars,
    deps,
    runtime_deps,
    exports,
    neverlink,
    srcjar,
    stamp,
)
```

`scala_import` enables the use of precompiled Scala .jar files as dependencies for other Scala rules
like `scala_library`, similar to `java_import` from Java rules.

This rule reimplements `java_import` without support for ijars, which break Scala macros.
Generally, ijars don’t help much for external dependencies, which rarely change.

The jar's compile MANIFEST.MD is stamped with a Target-Label attribute for dependency tracking 
reporting. This behaviour can be changed per `scala_import` target with an attribute or globally 
with a setting:
```
bazel build //my:target --//scala/settings:stamp_scala_import=False
```

## Attributes

| Attribute name        | Description                                           |
| --------------------- | ----------------------------------------------------- |
| name                  | `Name, required` <br> A unique name for this target.
| jars                  | `List of labels, required` <br> List of .jar files to import, usually in `//external`. In practice, this usually corresponds to one jar.
| deps                  | `List of labels, optional` <br> Compile time dependencies that were used to create the jar.
| runtime_deps          | `List of labels, optional` <br> Runtime dependencies that are needed for this library.
| exports               | `List of labels, optional` <br> List of targets to add to the dependencies of those that depend on this target.
| neverlink             | `boolean, optional (default False)` <br> If true only use this library for compilation and not at runtime.
| srcjar                | `Label, optional` <br> The source jar that was used to create the jar.
| stamp                 | `Label, optional` <br> Setting to control Target-Label stamping into compile jar Manifest <br> Default value is `@io_bazel_rules_scala//scala/settings:stamp_scala_import`