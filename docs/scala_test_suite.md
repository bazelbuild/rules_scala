# scala_test_suite

`scala_test_suite` allows you to define a glob or series of targets for which to generate sub scala tests.

The outer target defines a native test suite to run all the inner tests. This allows splitting up
of a series of independent tests from one target into several finer grained targets, enabling better caching
and parallelization of building & testing individual targets.