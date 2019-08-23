# thrift_library

```python
load("@io_bazel_rules_scala//thrift:thrift.bzl", "thrift_library")
thrift_library(
    name,
    srcs,
    deps,
    absolute_prefix,
    absolute_prefixes
)
```

`thrift_library` generates a thrift source zip file.

It should be consumed by a thrift compiler like `thrift_scala_library` in its `deps`.

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <p><code>Name, required</code></p>
        <p>A unique name for this target</p>
      </td>
    </tr>
      <td><code>srcs</code></td>
      <td>
        <p><code>List of labels, required</code></p>
        <p>List of Thrift <code>.thrift</code> source files used to build the target</p>
      </td>
    </tr>
    <tr>
      <td><code>deps</code></td>
      <td>
        <p><code>List of labels, optional</code></p>
        <p>List of other thrift dependencies that this thrift depends on.  Also can include `thrift_scala_import`
        targets, containing additional `thrift_jars` (which will be compiled) and/or `scala_jars` needed at compile time (such as Finagle).</p>
      </td>
    </tr>
    <tr>
      <td><code>absolute_prefix</code></td>
      <td>
        <p><code>string; optional (deprecated in favor of absolute_prefixes)</code></p>
        <p>This string acts as a wildcard expression of the form *`string_value` that is removed from the start of the path.
        Example: thrift is at `a/b/c/d/e/A.thrift` , prefix of `b/c/d`. Will mean other thrift targets can refer to this thrift
        at `e/A.thrift`.
        </p>
      </td>
    </tr>
    <tr>
      <td><code>absolute_prefixes</code></td>
      <td>
        <p><code>List of strings; optional</code></p>
        <p>Each of these strings acts as a wildcard expression of the form <code>*string_value</code> that is removed from the start of the path.
        Example: thrift is at <code>a/b/c/d/e/A.thrift</code> , prefix of <code>b/c/d</code>. Will mean other thrift targets can refer to this thrift
        at <code>e/A.thrift</code>. Exactly one of these must match all thrift paths within the target, more than one or zero will fail the build.
        The main use case to have several here is to make a macro target you can share across several indvidual <code>thrift_library</code>, if source path is
        <code>/src/thrift</code> or <code>/src/main/thrift</code> it can strip off the prefix without users needing to configure it per target.
        </p>
      </td>
    </tr>
  </tbody>
</table>
