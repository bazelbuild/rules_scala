# scala_rules Semanticdb example

This example demonstrates using an aspect to access the semanticdb info for one or more targets. In this example, an aspect is used to generate a json file that contains the semanticdb info that could be consumed by a consumer such as an IDE. 

In this example, note that a scala_toolchain with enable_semanticdb=True is setup in the BUILD file.

This command can be used to run the aspect (and not run the full build) 

```
bazel build //...  --aspects aspect.bzl%semanticdb_info_aspect --output_groups=json_output_file
```

The semanticdb_info.json file will be created for each target, and contains the semanticdb info for the target.