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