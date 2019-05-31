# scala_doc

```python
scala_binary(
    name,
    deps,
)
```

`scala_doc` generates [Scaladoc](https://docs.scala-lang.org/style/scaladoc.html) for sources
for targets, including sources from upstream deps. Readily hostable HTML is written to a `name.html` output folder.

Scaladoc can be somewhat slow to build. In that case, you can tell Bazel to build this target manually,
i.e. only when named explicitly and not through wildcards: `tags = ["manual"]`.

## Example

```python
scala_doc(
    name = "scala_docs",
    tags = ["manual"],
    deps = [
        ":target1",
        ":target2",
        ":anothertarget",
    ],
    scalacopts = [
        "-Ypartial-unification",
        "-Ywarn-unused-import",
    ],
)

# Use pkg_tar to tarball up
# https://docs.bazel.build/versions/master/be/pkg.html#pkg_tar
pkg_tar(
    name = "scala_docs_archive",
    srcs = [":scala_docs"],
    extension = "tar.gz",
)
```

## Attributes

| Attribute name        | Description                                           |
| --------------------- | ----------------------------------------------------- |
| name                  | `Name, required` <br> A unique name for this target.
| deps                  | `List of labels, optional` <br> Labels for which you want to create scaladoc.
| scalacopts            | `List of strings, optional` <br> Extra compiler options for this library to be passed to scalac.