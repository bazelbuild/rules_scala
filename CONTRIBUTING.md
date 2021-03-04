Want to contribute? Great! First, read this page (including the small print at the end).

### Before you contribute
**Before we can use your code, you must sign the
[Google Individual Contributor License Agreement](https://developers.google.com/open-source/cla/individual?csw=1)
(CLA)**, which you can do online.

The CLA is necessary mainly because you own the copyright to your changes,
even after your contribution becomes part of our codebase, so we need your
permission to use and distribute your code. We also need to be sure of
various other things — for instance that you'll tell us if you know that
your code infringes on other people's patents. You don't have to sign
the CLA until after you've submitted your code for review and a member has
approved it, but you must do it before we can put your code into our codebase.

Before you start working on a larger contribution, you should get in touch
with us first. Use the issue tracker to explain your idea so we can help and
possibly guide you.

### Code organization

Core Scala rules (including their implementations) and macros go in [./scala/private/rules/](./scala/private/rules/)
and [./scala/private/macros/](./scala/private/macros/), respectively, and are re-exported for public use
in [./scala/scala.bzl](./scala/scala.bzl).

### Code reviews and other contributions.
**All submissions, including submissions by project members, require review.**
Please follow the instructions in [the contributors documentation](http://bazel.io/contributing.html).

### The small print
Contributions made by corporations are covered by a different agreement than
the one above, the
[Software Grant and Corporate Contributor License Agreement](https://cla.developers.google.com/about/google-corporate).

### Working with Intellij bazel plugin
For your convenience, you can use [this](scripts/ij.bazelproject) .bazelproject file when you setup the bazel plugin in Intellij

### Formatting Fixes
Code formatting is checked as part of the CI pipeline. To check/fix formatting
you can use the `lint.sh` script:

```
./lint.sh check # check formatting
./lint.sh fix   # fix formatting
```

Note that Skylint failures are ignored and that the fix
command will modify your files in place.

### Additional Tests to Run
Some changes require running additional tests which are not currently
part of the CI pipeline.

When editing code in `./third_party`, please run `./dangerous_test_thirdparty_version.sh`
but read the comments at the beginning of the file first.
