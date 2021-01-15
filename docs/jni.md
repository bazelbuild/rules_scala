## jni usage

jni usage is supported by providing the dependency with the `data` attribute and explicitly specifying its path with the `java.library.path` flag: 

```
scala_binary(
    name = "main",
    data = ["//example/cc:my-jni"],
    jvm_flags = ["-Djava.library.path=example/cc"],
    ...
)

scala_test(
    name = "test",
    data = ["//example/cc:my-jni"],
    jvm_flags = ["-Djava.library.path=example/cc"],
    ...
)
```

A complete working example can be found in `examples/jni`.