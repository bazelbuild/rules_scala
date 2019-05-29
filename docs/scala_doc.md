# scala_doc

```python
scala_binary(
    name,
    deps,
    plugins,
)
```

`scala_doc` generates [Scaladoc](https://docs.scala-lang.org/style/scaladoc.html) for sources
for targets, including sources from upstream deps. Readily hostable HTML is written to a `name.html` output folder.

## Attributes

| Attribute name        | Description                                           |
| --------------------- | ----------------------------------------------------- |
| name                  | `Name, required` <br> A unique name for this target.
| deps                  | `List of labels, optional` <br> Labels for which you want to create scaladoc.
| plugins               | `List of labels, optional` <br> Scala compiler plugins to pass through to the scaladoc tool.