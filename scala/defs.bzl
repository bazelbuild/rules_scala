"""Starlark rules for building Scala projects.

These are the core rules (library, binary, test) under active
development. Their APIs are not guaranteed stable and we anticipate
some breaking changes.

We do not yet recommend using these APIs for production codebases. Instead,
use the stable rules exported by scala.bzl:

```
load(
    "@io_bazel_rules_scala//scala:scala.bzl",
    "scala_library",
    "scala_binary",
    "scala_test"
)
```

"""

load(
    "@io_bazel_rules_scala//scala/private:rules/scala_binary.bzl",
    _make_scala_binary = "make_scala_binary",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_library.bzl",
    _make_scala_library = "make_scala_library",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/unstable_scala_test.bzl",
    _make_scala_test = "make_scala_test",
)

make_scala_library = _make_scala_library
make_scala_binary = _make_scala_binary
make_scala_test = _make_scala_test

scala_library = _make_scala_library()
scala_binary = _make_scala_binary()
scala_test = _make_scala_test()
