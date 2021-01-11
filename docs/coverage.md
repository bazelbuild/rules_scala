## Coverage support

### Running tests with coverage

rules_scala supports coverage:

```
bazel coverage //...
```

It will produce several .dat files with results for your targets.

You can also add more options to receive a combined coverage report:

```
bazel coverage \
  --combined_report=lcov \
  --coverage_report_generator="@bazel_tools//tools/test/CoverageOutputGenerator/java/com/google/devtools/coverageoutputgenerator:Main" \
  //...
```

This should produce a single `bazel-out/_coverage/_coverage_report.dat` from all coverage files that are generated.

### Processing coverage reports

You can install `lcov` package (that supports the format Bazel uses for coverage reports) to have access to additional tools:

```
# Use your system package manager. E.g. on Ubuntu:
sudo apt install lcov
```

Having `lcov` package installed you can extract information from your coverage reports:

```
# For a summary:
lcov --summary your-coverage-report.dat
# For details:
lcov --list your-coverage-report.dat
```

If you prefer an HTML report, then you can use `genhtml` provided also by the `lcov` package.

An example with a bit of ceremony:

```bash
# Output html reports to a new directory.
destdir="my-coverage-reports"
mkdir -p ${destdir}

# Generate HTML report from the results.
genhtml -o ${destdir} --ignore-errors source bazel-out/_coverage/_coverage_report.dat

echo "coverage report at file://${destdir}/index.html"

```

### Support for testing frameworks

Coverage support has been only tested with [ScalaTest](http://www.scalatest.org/).

### Working around missing lambda coverage with Scala 2.12+

The current Jacoco version in Bazel (0.8.3) has missing coverage for lambdas
(including for comprehensions; see issue https://github.com/bazelbuild/rules_scala/issues/1056).
This can be worked around by building a fixed version of Jacoco yourselves (including backported fixes from 0.8.5) and reconfiguring your
build to use that one instead of the default `jacocorunner`.

You can build jacocorunner with a script in `scripts/build_jacocorunner/build_jacocorunner.sh` (see comments there for more explanation and options).

Then, you can use the `jacocorunner` property of `scala_toolchain` to provide the jacocorunner you have built:

```
# Example contents of coverage_local_jacocorunner/BUILD
scala_toolchain(
    name = "local_jacocorunner_toolchain_impl",
    jacocorunner = ":local_jacocorunner",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "local_jacocorunner_scala_toolchain",
    toolchain = "local_jacocorunner_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "local_jacocorunner",
    srcs = ["JacocoCoverage_jarjar_deploy.jar"],
)
```

In this example `jacocorunner` is provided as a local file, but you could also upload your version to an artifactory and then use `http_file` (to avoid
keeping binaries in your repository).

Finally provide the `scala_toolchain` in your `.bazelrc` or as an option to `bazel coverage`:

```
coverage --extra_toolchains="//coverage_local_jacocorunner:local_jacocorunner_scala_toolchain"
```

You can verify that the locally built `jacocorunner` works with `manual_test/coverage_local_jacocorunner/test.sh`.
