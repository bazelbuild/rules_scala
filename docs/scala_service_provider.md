# scala_service_provider
TODO: this is copy/pasted from scala_doc so far
```python
scala_service_provider(
    name,
    srcs,
    deps,
    runtime_deps,
    exports,
    data,
    main_class,
    resources,
    resource_strip_prefix,
    scalacopts,
    jvm_flags,
    scalac_jvm_flags,
    javac_jvm_flags,
    unused_dependency_checker_mode,
    services
)
```

A scala service provider is a thin wrapper around a [`scala_library`](scala_library.md), which
expects one additional argument: `services`.
`services` is a dictionary where the keys are strings representing one service API and the values
are a list of implementations for that service.
If the `services` attribute is provided, the services matching this attribute will be added to the
output jar under the `META-INF/services` directory, as prescribed by the [Service Provider
Interface protocol](https://docs.oracle.com/javase/tutorial/ext/basics/spi.html)

## Example

```python
scala_service_provider(
    name = "a_scala_service_provider",
    srcs = ["TestServer.scala"],
    deps = ["//test/proto:test_proto"],
    services = {"com.scala.test.service": ["com.scala.test.Service1","com.scala.test.Service2",],}
)


```

## Attributes

Please refer to `scala_library` for all the attributes but the `services` attribute.

| Attribute name        | Description                                           |
| --------------------- | ----------------------------------------------------- |
| services              | `Dict of strings to list of strings`<br>Mapping between services and their implementations`
