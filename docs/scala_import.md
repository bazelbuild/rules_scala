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
| deps                  | `List of labels, optional` <br>
| runtime_deps          | `List of labels, optional` <br>
| exports               | `List of labels, optional` <br> List of targets to add to the dependencies of those that depend on this target.
| neverlink             | `boolean, optional (default False)` <br>
| srcjar                | `Label, optional` <br>