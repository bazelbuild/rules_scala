# Coverage support

## Running tests with coverage

rules_scala supports coverage:

```txt
bazel coverage //...
```

It will produce several .dat files with results for your targets.

You can also add more options to receive a combined coverage report:

```txt
bazel coverage \
  --combined_report=lcov \
  --coverage_report_generator="@bazel_tools//tools/test/CoverageOutputGenerator/java/com/google/devtools/coverageoutputgenerator:Main" \
  //...
```

This should produce a single `bazel-out/_coverage/_coverage_report.dat` from all coverage files that are generated.

## Processing coverage reports

You can install the [`lcov`](https://github.com/linux-test-project/lcov) package (that supports the format Bazel uses for coverage reports) to have access to additional tools:

```txt
# Use your system package manager. E.g. on Ubuntu:
sudo apt install lcov
```

Having `lcov` package installed you can extract information from your coverage reports:

```txt
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

## Support for testing frameworks

Coverage support has been only tested with [ScalaTest](http://www.scalatest.org/).

## JaCoCo

`rules_scala` uses the [JaCoCo](https://www.jacoco.org/jacoco/) library imported
by the underlying [`rules_java`](https://github.com/bazelbuild/rules_java)
module to generate code coverage. `rules_java`, in turn, imports JaCoCo via the
[`java_tools`](https://github.com/bazelbuild/java_tools) repository, built from
the [tools/jdk/BUILD.java_tools](
https://github.com/bazelbuild/bazel/blob/master/tools/jdk/BUILD.java_tools) file
and [third_party/java/jacoco](
https://github.com/bazelbuild/bazel/blob/master/third_party/java/jacoco/BUILD)
package in the Bazel source. `java_tools` and `rules_java` are released more
frequently than Bazel itself, decoupling them from the Bazel release cycle.

To check the version of JaCoCo used by a specific version of `rules_java`:

- Open [`java/repositories.bzl` in the `rules_java` source](
    https://github.com/bazelbuild/rules_java/blob/master/java/repositories.bzl).

- Select a specific version of `rules_java` using the **Switch branches/tabs**
    dropdown menu.

  - Alternatively, replace `master` with the `rules_java` version in the
      `java/repositories.bzl` URL.

- Make note of the version of `java_tools` specified in the `JAVA_TOOLS_CONFIG`
    dictionary. For example, [`rules_java` 8.9.0 uses `java_tools` v.13.16](
    https://github.com/bazelbuild/rules_java/blob/8.9.0/java/repositories.bzl#L49).

- Download the `java_tools` archive using the archive URL:

    ```txt
    curl -LO https://mirror.bazel.build/bazel_java_tools/releases/java/v13.16/java_tools-v13.16.zip
    ```

- Unzip the archive, then inspect the top level `BUILD` file:

    ```sh
    $ grep 'jacoco\.core-' BUILD

        jars = ["java_tools/third_party/java/jacoco/org.jacoco.core-0.8.11.jar"],
        srcjar = "java_tools/third_party/java/jacoco/org.jacoco.core-0.8.11-sources.jar",
        srcs = ["java_tools/third_party/java/jacoco/org.jacoco.core-0.8.11.jar"],
    ```

| `rules_java` version | `java_tools` version | JaCoCo version |
| :-: | :-: | :-: |
| [8.9.0](https://github.com/bazelbuild/rules_java/blob/8.9.0/java/repositories.bzl#L49) | v13.16 | [0.8.11][JaCoCo version] |
| [7.12.4](https://github.com/bazelbuild/rules_java/blob/7.12.4/java/repositories.bzl#L49) | v13.9 | [0.8.11][JaCoCo version] |

For information on updating the [JaCoCo version][] used by `rules_java`,
`java_tools`, and Bazel, see [Bazel's &quot;Upgrading Jacoco version&quot;
README](
https://github.com/bazelbuild/bazel/blob/master/third_party/java/jacoco/README.md).

[JaCoCo version]: https://www.jacoco.org/jacoco/trunk/doc/changes.html

## Working around missing JaCoCo features

The version of JaCoCo that ships with `rules_java` may lack support for newer
Scala features. To work around this, build an updated version of JaCoCo and
configure the project to use this new artifact instead of the default
`jacocorunner`.

You can build jacocorunner with a script in `scripts/build_jacocorunner/build_jacocorunner.sh` (see comments there for more explanation and options).

Then, you can use the `jacocorunner` property of `scala_toolchain` to provide the jacocorunner you have built:

```py
# Example contents of coverage_local_jacocorunner/BUILD
scala_toolchain(
    name = "local_jacocorunner_toolchain_impl",
    jacocorunner = ":local_jacocorunner",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "local_jacocorunner_scala_toolchain",
    toolchain = "local_jacocorunner_toolchain_impl",
    toolchain_type = "@rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "local_jacocorunner",
    srcs = ["JacocoCoverage_jarjar_deploy.jar"],
)
```

In this example `jacocorunner` is provided as a local file, but you could also upload your version to an artifactory and then use `http_file` (to avoid
keeping binaries in your repository).

Finally, provide the `scala_toolchain` in your `.bazelrc` or as an option to `bazel coverage`:

```txt
coverage --extra_toolchains="//coverage_local_jacocorunner:local_jacocorunner_scala_toolchain"
```

You could also register the toolchain in your `WORKSPACE`.

You can verify that the locally built `jacocorunner` works with `manual_test/coverage_local_jacocorunner/test.sh`.

## Notes

Please ensure these scripts use Java 8.

This should be done in the script itself, as e.g. the manual test requires a higher Java version, so you could add some
code at the header of the build script to select Java 8 (appropriate for your Java installation).
