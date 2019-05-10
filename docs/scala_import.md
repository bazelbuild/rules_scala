# scala_import

```python
scala_import(
    name,
    jars,
    deps,
    runtime_deps,
    exports,
    neverlink,
    srcjar
)
```

`scala_import` enables the use of precompiled Scala .jar files as dependencies for other Scala rules
like `scala_library`, similar to `java_import` from Java rules.

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