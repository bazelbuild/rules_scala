# scala_test

```python
scala_test(
    name,
    srcs,
    suites,
    deps,
    data,
    main_class,
    resources,
    resource_strip_prefix,
    scalacopts,
    jvm_flags,
    scalac_jvm_flags,
    javac_jvm_flags,
    unused_dependency_checker_mode
)
```

`scala_test` generates a Scala executable which runs unit test suites written
using the `scalatest` library. It may depend on `scala_library`,
`scala_macro_library` and `java_library` rules.

By default, `scala_test` runs _all_ tests in a given target.
For backwards compatibility, it accepts a `suites` attribute which
is ignored due to the ease with which that field is not correctly
populated and tests are not run.